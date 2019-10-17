# frozen_string_literal: true

class NkfMember < ApplicationRecord
  # `map_to` is used to set a new value in the RJJK model.
  FIELD_MAP = {
    adresse_1: {},
    adresse_2: { map_to: { user: :address }, form_field: :frm_48_v05 },
    adresse_3: {},
    antall_etiketter_1: {},
    betalt_t_o_m__dato: {},
    created_at: {},
    epost: { map_to: { user: :contact_email }, form_field: :frm_48_v10 },
    epost_faktura: { map_to: { billing: :email }, form_field: :frm_48_v22 },
    etternavn: { map_to: { user: :last_name }, form_field: :frm_48_v04 },
    fodselsdato: { map_to: { user: :birthdate }, form_field: :frm_48_v08 },
    foresatte: { map_to: { user: :guardian_1_or_billing_name }, form_field: :frm_48_v23 },
    foresatte_epost: { map_to: { guardian_1: :email }, form_field: :frm_48_v73 },
    foresatte_mobil: { map_to: { guardian_1: :phone }, form_field: :frm_48_v74 },
    foresatte_nr_2: { map_to: { guardian_2: :name }, form_field: :frm_48_v72 },
    foresatte_nr_2_mobil: { map_to: { guardian_2: :phone }, form_field: :frm_48_v75 },
    fornavn: { map_to: { user: :first_name }, form_field: :frm_48_v03 },
    gren_stilart_avd_parti___gren_stilart_avd_parti: {},
    hovedmedlem_id: {},
    hovedmedlem_navn: {},
    id: {},
    innmeldtarsak: {},
    innmeldtdato: { map_to: { membership: :joined_on }, form_field: :frm_48_v45 },
    # form_field: :frm_48_v112 values: true: 'M' or false: 'K'
    kjonn: { map_to: { user: :male } },
    klubb: {},
    klubb_id: {},
    konkurranseomrade_id: {},
    konkurranseomrade_navn: {},
    kont_belop: {}, # FIXME(uwe): Map payment values
    kont_sats: {
      map_to: { membership: :category },
      # form_field: :frm_48_v36
    },
    kontraktsbelop: { map_to: { membership: :monthly_fee } },
    kontraktstype: {
      map_to: { membership: :contract },
      # form_field: :frm_48_v37
    },
    medlemskategori: {},
    medlemskategori_navn: {
      map_to: { membership: :category },
      # form_field: :frm_48_v48
    },
    medlemsnummer: {},
    medlemsstatus: {}, # FIXME(uwe): Should be mapped: passive_from+left_on => 'A', 'P'
    member_id: {},
    mobil: { map_to: { user: :phone }, form_field: :frm_48_v20 },
    postnr: { map_to: { user: :postal_code }, form_field: :frm_48_v07 },
    rabatt: {
      map_to: { membership: :discount },
      # form_field: :frm_48_v38
    },
    sist_betalt_dato: {},
    sted: {},
    telefon: { map_to: { membership: :phone_home }, form_field: :frm_48_v19 },
    telefon_arbeid: { map_to: { membership: :phone_work }, form_field: :frm_48_v21 },
    updated_at: {},
    utmeldtarsak: {},
    utmeldtdato: { map_to: { membership: :left_on }, form_field: :frm_48_v46 },
    ventekid: {},
    yrke: {},
  }.freeze

  has_paper_trail

  belongs_to :member, optional: true

  validates :kjonn, presence: true
  validates :member_id, uniqueness: { allow_nil: true }

  def self.find_free_members
    Member
        .where("(left_on IS NULL OR left_on >= '2009-01-01')")
        .where('id NOT IN (SELECT member_id FROM nkf_members WHERE member_id IS NOT NULL)')
        .order(:id).to_a
  end

  def self.update_group_prices
    contract_types = NkfMember.all.group_by(&:kontraktstype)
    contract_types.each do |contract_name, members_with_contracts|
      monthly_fee = members_with_contracts.map(&:kontraktsbelop)
          .group_by { |x| x }.group_by { |_k, v| v.size }.max.last
          .map(&:first).first
      yearly_fee = members_with_contracts.map(&:kont_belop).group_by { |x| x }
          .group_by { |_k, v| v.size }.max.last.map(&:first).first
      Group.where(contract: contract_name).to_a.each do |group|
        logger.info "Update contract #{group} #{contract_name} #{monthly_fee} #{yearly_fee}"
        group.update! monthly_fee: monthly_fee, yearly_fee: yearly_fee
      end
    end
  end

  def mapping_attributes
    attributes.map(&method(:rjjk_attribute))
  end

  def mapping_changes
    mapping_attributes.select do |a|
      next if utmeldtdato.present? && a[:nkf_attr] != 'utmeldtdato'

      a[:target] && a[:mapped_rjjk_value] != a[:nkf_value] &&
          a[:mapped_rjjk_value] != a[:nkf_value]&.downcase
    end
  end

  def rjjk_attribute(nkf_attr, nkf_value)
    logger.error "rjjk_attribute: nkf_attr: #{nkf_attr.inspect}, nkf_value: #{nkf_value.inspect}"
    mapping = FIELD_MAP[nkf_attr.to_sym]
    raise "Unknown attribute: #{nkf_attr}" unless mapping

    if (mapped_attribute = mapping[:map_to])
      target, target_attribute = mapped_attribute.to_a[0]
      relation = NkfMemberComparison.target_relation(member, target) if member
      rjjk_value = relation&.send(target_attribute)
      mapped_rjjk_value =
          if rjjk_value.is_a?(Date)
            rjjk_value.strftime('%d.%m.%Y')
          elsif nkf_attr == 'kjonn'
            rjjk_value ? 'Mann' : 'Kvinne'
          else
            rjjk_value.to_s
          end
      mapped_nkf_value =
          if /^\s*(?<day>\d{2})\.(?<month>\d{2})\.(?<year>\d{4})\s*$/ =~ nkf_value
            Date.new(year.to_i, month.to_i, day.to_i)
          elsif /Mann|Kvinne/.match?(nkf_value)
            nkf_value == 'Mann'
          elsif nkf_value.blank? && (target =~ /^(billing|guardian_)/ ||
              target_attribute =~ /^guardian_|email|mobile|phone|_on$/)
            nil
          elsif nkf_value.blank? && (target == :user && User::NILLABLE_FIELDS.include?(target_attribute))
            nil
          elsif nkf_value.present? && target_attribute =~ /email/
            nkf_value.downcase
          else
            nkf_value
          end
      # else
      #   logger.debug "rjjk_attribute: Ignore attribute: #{nkf_attr}: #{nkf_value.inspect}"
    end
    { nkf_attr: nkf_attr, target: target, target_attribute: target_attribute, nkf_value: nkf_value,
      mapped_nkf_value: mapped_nkf_value, rjjk_value: rjjk_value, mapped_rjjk_value: mapped_rjjk_value,
      form_field: mapping[:form_field] }
  end

  def converted_attributes(include_blank: true)
    new_attributes = Hash.new { |hash, key| hash[key] = {} }
    attributes.each do |nkf_attr, nkf_value|
      target, target_attribute, mapped_value = rjjk_attribute(nkf_attr, nkf_value)
          .values_at(:target, :target_attribute, :mapped_nkf_value)
      next unless target && target_attribute &&
          (include_blank || mapped_value.present? || mapped_value == false)

      new_attributes[target][target_attribute] = mapped_value
    end
    user_email = new_attributes.dig(:user, :email)
    email_contact_user = User.find_by(email: user_email) if user_email.present?
    logger.info "email_contact_user: #{email_contact_user.inspect}"

    if new_attributes.dig(:billing, :email)&.== new_attributes.dig(:guardian_1, :email)
      logger.info 'converted_attributes: resetting billing email since it equals parent email'
      new_attributes[:billing].delete(:email)
      new_attributes.delete(:billing) if new_attributes[:billing].empty?
    end

    secondary_emails = [new_attributes.dig(:billing, :email), new_attributes.dig(:guardian_1, :email),
                        new_attributes.dig(:guardian_2, :email)].compact
    if secondary_emails.include?(user_email)
      logger.error 'reset user email since it equals a secondary email: ' \
            "#{new_attributes[:user][:email].inspect}"
      if include_blank
        new_attributes[:user][:email] = nil
      else
        new_attributes[:user].delete(:email)
        new_attributes.delete(:user) if new_attributes[:user].empty?
      end
    end

    user_phone = new_attributes.dig(:user, :phone)
    phone_contact_user = User.find_by(email: user_phone) if user_phone.present?
    logger.info "phone_contact_user: #{phone_contact_user.inspect}"

    secondary_phones = [new_attributes.dig(:billing, :phone), new_attributes.dig(:guardian_1, :phone),
                        new_attributes.dig(:guardian_2, :phone)].compact
    if secondary_phones.include?(new_attributes.dig(:user, :phone))
      logger.error 'reset user phone since it equals a secondary phone: ' \
            "#{new_attributes[:user][:phone].inspect}"
      if include_blank
        new_attributes[:user][:phone] = nil
      else
        new_attributes[:user].delete(:phone)
        new_attributes.delete(:user) if new_attributes[:user].empty?
      end
    end

    new_attributes[:membership].delete(:category)
    new_attributes[:membership].delete(:contract)
    new_attributes[:membership].delete(:discount)
    new_attributes[:membership].delete(:monthly_fee)

    new_attributes
  end

  MEMBER_DEFAULT_ATTRIBUTES = { instructor: false, nkf_fee: true, payment_problem: false }.freeze

  def create_corresponding_member!
    transaction do
      attributes = converted_attributes(include_blank: false)
      membership_attributes = attributes[:membership]
      user_attributes = attributes[:user]
      billing_attributes = attributes[:billing]
      guardian_1_attributes = attributes[:guardian_1]
      guardian_2_attributes = attributes[:guardian_2]

      logger.error "membership_attributes: #{membership_attributes.inspect}"
      logger.error "user_attributes: #{user_attributes.inspect}"

      contact_email = user_attributes.delete(:contact_email)
      guardian_1_or_billing_name = user_attributes.delete(:guardian_1_or_billing_name)
      unless [guardian_1_attributes[:email], guardian_2_attributes[:email], billing_attributes[:email]]
            .include?(contact_email)
        user_attributes[:email] = contact_email
        if (existing_email_user = (contact_email && User.find_by(email: contact_email)))
          logger.info "Found existing email user: #{existing_email_user.inspect}"
          user = existing_email_user
          if user_attributes[:phone].present?
            User.where(phone: user_attributes[:phone]).find_each do |u|
              logger.info "Reset phone for conflicting phone user: #{u.inspect}"
              u.update! phone: nil
            end
          end
          user.update! user_attributes
        elsif (existing_phone_user =
                   (user_attributes[:phone] && User.find_by(phone: user_attributes[:phone])))
          logger.info "Found existing phone user: #{existing_phone_user.inspect}"
          existing_phone_user.guardians.each do |gu|
            next if gu.phone

            phone = user_attributes.delete(:phone)
            logger.info "promoting phone #{phone} from #{user_attributes} to #{gu.name}"
            existing_phone_user.update! phone: nil
            gu.update! phone: phone
            break
          end
          if user_attributes[:phone]
            if (existing_phone_member = Member.find_by(user_id: existing_phone_user.id))
              logger.info "Existing phone user already mapped to membership: #{user_attributes.inspect}: #{existing_phone_member.inspect}" # rubocop: disable Metrics/LineLength
              if user_attributes[:birthdate] < existing_phone_member.birthdate
                logger.info 'Keeping phone for new membership due to higher age'
                existing_phone_member.user.update! phone: nil
              else
                logger.info 'Keeping phone for existing membership due to higher age'
                user_attributes.delete(:phone)
              end
            else
              logger.info "Using existing phone user: #{user_attributes.inspect}: #{existing_phone_user.inspect}" # rubocop: disable Metrics/LineLength
              user = existing_phone_user
              user.update! user_attributes
            end
          end
        end
      end

      unless user
        logger.info "Creating new user: #{user_attributes.inspect}"
        user = User.new user_attributes
        logger.info "New user: #{user.inspect}"
      end

      if billing_attributes.present?
        logger.info "billing_attributes: #{billing_attributes.inspect}"
        if user.billing_user
          user.billing_user.update! billing_attributes
        else
          billing_user = (billing_attributes[:email] && User.find_by(email: billing_attributes[:email])) ||
              (billing_attributes[:phone] && User.find_by(phone: billing_attributes[:phone])) ||
              (billing_attributes[:first_name] && billing_attributes[:last_name] &&
                  User.find_by(first_name: billing_attributes[:first_name],
                      last_name: billing_attributes[:last_name])) ||
              User.new
          logger.info 'Create new billing user' if billing_user.new_record?
          logger.info "billing_user: #{billing_user.inspect}"
          billing_user.attributes = billing_attributes
          logger.info "billing_user updated: #{billing_user.changes.inspect}" if billing_user.changed?
          billing_user.save!
          user.billing_user = billing_user
        end
      end

      if guardian_1_attributes.present?
        logger.info "guardian_1_attributes: #{guardian_1_attributes.inspect}"
        if user.guardian_1
          user.guardian_1.update! guardian_1_attributes
        else
          guardian_1 =
              (guardian_1_attributes[:email] && User.find_by(email: guardian_1_attributes[:email])) ||
              (guardian_1_attributes[:phone] && User.find_by(phone: guardian_1_attributes[:phone])) ||
              User.new
          logger.info 'create new guardian_1 user' if guardian_1.new_record?
          guardian_1.update!(guardian_1_attributes)
          user.guardian_1 = guardian_1
        end
      end

      if guardian_2_attributes.present?
        logger.info "guardian_2_attributes: #{guardian_2_attributes.inspect}"
        if user.guardian_2
          user.guardian_2.update! guardian_2_attributes
        else
          guardian_2 =
              (guardian_2_attributes[:email] && User.find_by(email: guardian_2_attributes[:email])) ||
              (guardian_2_attributes[:phone] && User.find_by(phone: guardian_2_attributes[:phone])) ||
              User.new
          guardian_2.attributes = guardian_2_attributes
          if guardian_2.contact_info?
            logger.info 'Create new guardian_2 user' if guardian_2.new_record?
            guardian_2.save!(guardian_2_attributes)
            user.guardian_2 = guardian_2
          else
            logger.info 'Ignoring guardian_2 user without contact information.'
          end
        end
      end

      user.guardian_1_or_billing_name = guardian_1_or_billing_name

      user.save!

      member_attributes_with_defaults = membership_attributes.update(MEMBER_DEFAULT_ATTRIBUTES)

      logger.error "membership users: #{{ user: user }}"
      member = build_member(user: user)

      logger.error "member_attributes_with_defaults: #{member_attributes_with_defaults}"
      member.update! member_attributes_with_defaults
      member.update! user: user # FIXME(uwe):  Why is this needed?  Remove!

      member_groups = if (nkf_group_names = group_names).any?
                        logger.info "Adding groups from NKF: #{nkf_group_names}"
                        Group.where(name: nkf_group_names)
                      else
                        logger.info "Adding groups by age: #{member.age}"
                        Group.active.where(from_age: 0..member.age, to_age: member.age..100)
                      end
      member.groups = member_groups.to_a
      member.save!

      member
    end
  end

  def group_names
    gren_stilart_avd_parti___gren_stilart_avd_parti.split(/ - /).map { |n| n.split('/')[3] }
  end

  def to_s
    "#{fornavn} #{etternavn}"
  end
end
