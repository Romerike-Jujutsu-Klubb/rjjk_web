# frozen_string_literal: true

class NkfMember < ApplicationRecord
  include NkfAttributeConversion

  has_paper_trail

  belongs_to :member, optional: true
  has_one :user, through: :member

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

  def converted_attributes(include_blank: true)
    new_attributes = Hash.new { |hash, key| hash[key] = {} }
    MAPPED_FIELDS.each do |nkf_attr, mapping|
      target, target_attribute, mapped_value = rjjk_attribute(nkf_attr, mapping)
          .values_at(:target, :target_attribute, :mapped_nkf_value)
      next unless target && target_attribute &&
          (include_blank || mapped_value.present? || mapped_value == false)

      new_attributes[target][target_attribute] = mapped_value
    end
    user_email = new_attributes.dig(:user, :contact_email)
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
      logger.error "reset user email since it equals a secondary email: #{user_email.inspect}"
      if include_blank
        new_attributes[:user][:contact_email] = nil
      else
        new_attributes[:user].delete(:contact_email)
        new_attributes.delete(:user) if new_attributes[:user].empty?
      end
    end

    user_phone = new_attributes.dig(:user, :phone)
    phone_contact_user = User.find_by(phone: user_phone) if user_phone.present?
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
      logger.info "contact_email: #{contact_email.inspect}"
      guardian_1_or_billing_name = user_attributes.delete(:guardian_1_or_billing_name)
      logger.info "guardian_1_or_billing_name: #{guardian_1_or_billing_name.inspect}"

      if contact_email == billing_attributes[:email] && billing_attributes[:name].blank?
        billing_attributes.delete(:email)
      end

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
              logger.info <<~LINE
                Existing phone user already mapped to membership: #{user_attributes.inspect}: #{existing_phone_member.inspect}
              LINE
              if user_attributes[:birthdate] < existing_phone_member.birthdate
                logger.info 'Keeping phone for new membership due to higher age'
                existing_phone_member.user.update! phone: nil
              else
                logger.info 'Keeping phone for existing membership due to higher age'
                user_attributes.delete(:phone)
              end
            else
              logger.info <<~LINE
                Using existing phone user: #{user_attributes.inspect}: #{existing_phone_user.inspect}
              LINE
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
            guardian_2.save!(**guardian_2_attributes)
            user.guardian_2 = guardian_2
          else
            logger.info 'Ignoring guardian_2 user without contact information.'
          end
        end
      end

      user.guardian_1_or_billing_name = guardian_1_or_billing_name
      if (u = user.guardian_1) && u.new_record? && !u.contact_info?
        if user.email.present? && (u2 = User.find_by(email: user.email))
          user.email = nil
          if u2.phone.nil? || u2.phone == user.phone
            u2.phone = user.phone
            user.phone = nil
          end
          user.guardian_1 = u2
        elsif user.phone.present? && (u2 = User.find_by(phone: user.phone))
          user.phone = nil
          if u2.email.nil? || u2.email == user.email
            u2.email = user.email
            user.email = nil
          end
          user.guardian_1 = u2
        else
          u.email = user.email
          u.phone = user.phone
          user.email = nil
          user.phone = nil
        end
      end

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
                        logger.info "Adding groups by age: #{user.age}"
                        Group.active.where(from_age: 0..user.age, to_age: user.age..100)
                      end
      user.groups = member_groups.to_a
      user.save!

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
