# frozen_string_literal: true

module NkfAttributeConversion
  # `map_to` is used to set a new value in the RJJK model.
  FIELD_MAP = {
    adresse_1: {},
    adresse_2: { map_to: { user: :address },
                 form_field: { member: :frm_48_v05, new_trial: :frm_29_v05, trial: :frm_28_v10 } },
    adresse_3: { form_field: { trial: :frm_28_v } },
    antall_etiketter_1: {},
    betalt_t_o_m__dato: {},
    created_at: {},
    epost: { map_to: { user: :contact_email },
             form_field: { member: :frm_48_v10, new_trial: :frm_29_v10, trial: :frm_28_v24 } },
    epost_faktura: { map_to: { billing: :email },
                     form_field: { member: :frm_48_v22, new_trial: :frm_29_v22, trial: :frm_28_v25 } },
    etternavn: { map_to: { user: :last_name },
                 form_field: { member: :frm_48_v04, new_trial: :frm_29_v04, trial: :frm_28_v09 } },
    fodselsdato: { map_to: { user: :birthdate },
                   form_field: { member: :frm_48_v08, new_trial: :frm_29_v08, trial: :frm_28_v14 } },
    foresatte: { map_to: { user: :guardian_1_or_billing_name },
                 form_field: { member: :frm_48_v23, new_trial: :frm_29_v23, trial: :frm_28_v26 } },
    foresatte_epost: { map_to: { guardian_1: :email },
                       form_field: { member: :frm_48_v73, new_trial: :frm_29_v73, trial: :frm_a28_v73 } },
    foresatte_mobil: { map_to: { guardian_1: :phone },
                       form_field: { member: :frm_48_v74, new_trial: :frm_29_v74, trial: :frm_a28_v74 } },
    foresatte_nr_2: { map_to: { guardian_2: :name },
                      form_field: { member: :frm_48_v72, new_trial: :frm_29_v72, trial: :frm_a28_v72 } },
    foresatte_nr_2_mobil: { map_to: { guardian_2: :phone }, form_field: {
      member: :frm_48_v75, new_trial: :frm_29_v75, trial: :frm_a28_v75
    } },
    fornavn: { map_to: { user: :first_name },
               form_field: { member: :frm_48_v03, new_trial: :frm_29_v03, trial: :frm_28_v08 } },
    # 524 : Jujutsu (Ingen stilartstilknytning)
    gren_stilart_avd_parti___gren_stilart_avd_parti: {
      map_to: { membership: :martial_art_name },
      form_field: { new_trial: :frm_29_v16, trial: :frm_28_v28 },
    },
    hovedmedlem_id: {},
    hovedmedlem_navn: {},
    hoyde: { map_to: { user: :height },
             form_field: { member: :frm_48_v13, new_trial: :frm_29_v13, trial: :frm_28_v16 } },
    id: {},
    innmeldtarsak: {},
    innmeldtdato: { map_to: { membership: :joined_on },
                    form_field: { member: :frm_48_v45, trial: :frm_28_v64 } },
    kjonn: { map_to: { user: :male },
             form_field: { member: :frm_48_v112, new_trial: :frm_29_v11, trial: :frm_28_v15 },
             values: { true => 'M', false => 'K' } },
    klubb: {},
    klubb_id: {},
    konkurranseomrade_id: {},
    konkurranseomrade_navn: {},
    kont_belop: {}, # FIXME(uwe): Map payment values
    kont_sats: { map_to: { membership: :category },
                 form_field: { member: :frm_48_v36, trial: :frm_28_v34 },
                 depends: :medlemskategori_navn },
    kontraktsbelop: { map_to: { membership: :monthly_fee }, form_field: { trial: :frm_28_v63 } },
    kontraktstype: { map_to: { membership: :contract },
                     form_field: { member: :frm_48_v37, trial: :frm_28_v36 },
                     depends: :kont_sats },
    medlemskategori: {},
    medlemskategori_navn: { map_to: { membership: :category },
                            form_field: { member: :frm_48_v48, trial: :frm_28_v17 } },
    medlemsnummer: {},
    medlemsstatus: {}, # FIXME(uwe): Should be mapped: passive_from+left_on => 'A', 'P'
    member_id: {},
    mobil: { map_to: { user: :phone },
             form_field: { member: :frm_48_v20, new_trial: :frm_29_v20, trial: :frm_28_v22 } },
    postnr: { map_to: { user: :postal_code },
              form_field: { member: :frm_48_v07, new_trial: :frm_29_v07, trial: :frm_28_v12 } },
    rabatt: { map_to: { membership: :discount }, form_field: { member: :frm_48_v38, trial: :frm_28_v35 } },
    reg_dato: { map_to: { trial: :reg_dato }, form_field: { trial: :frm_28_v32 } },
    sist_betalt_dato: {},
    sted: {},
    telefon: { map_to: { membership: :phone_home },
               form_field: { member: :frm_48_v19, new_trial: :frm_29_v19, trial: :frm_28_v21 } },
    telefon_arbeid: { map_to: { membership: :phone_work },
                      form_field: { member: :frm_48_v21, new_trial: :frm_29_v21, trial: :frm_28_v23 } },
    updated_at: {},
    utmeldtarsak: {},
    utmeldtdato: { map_to: { membership: :left_on }, form_field: { member: :frm_48_v46 } },
    ventekid: {},
    yrke: {},
  }.freeze

  MAPPED_FIELDS = FIELD_MAP.select { |_nkf_attr, mapping| mapping[:map_to] }.freeze

  def mapping_attributes(form)
    MAPPED_FIELDS.select { |_nkf_attr, mapping| mapping[:form_field][form] }
        .map { |nkf_atr, f| rjjk_attribute(nkf_atr, f) }
  end

  def mapping_changes
    mapping_attributes(:member).select do |a|
      next if utmeldtdato.present? && a[:nkf_attr] != :utmeldtdato

      a[:target] && a[:mapped_rjjk_value] != a[:nkf_value]
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

  def create_corresponding_user!(attributes)
    user_attributes = attributes[:user]
    billing_attributes = attributes[:billing]
    guardian_1_attributes = attributes[:guardian_1]
    guardian_2_attributes = attributes[:guardian_2]

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
    user
  end

  private

  def target_relation(target, nkf_values = {})
    case target
    when :membership
      member
    when :user
      user
    when :billing
      if nkf_values.any? { |_k, v| v.present? }
        if nkf_values[:email] && (existing_email_user = User.find_by(email: nkf_values[:email]))
          logger.info "Use existing billing user: #{existing_email_user}"
          user.billing_user = existing_email_user
          existing_email_user
        elsif user.billing_user
          user.billing_user
        else
          logger.info "Create new billing user: #{nkf_values}"
          user.build_billing_user
        end
      else
        user&.billing_user
      end
    when :guardian_1
      user&.guardian_1 ||
          ((nkf_values.any? { |_k, v| v.present? } || nil) && user&.build_guardian_1)
    when :guardian_2
      user&.guardian_2 ||
          ((nkf_values.any? { |_k, v| v.present? } || nil) && user&.build_guardian_2)
    when :trial
      begin
        nkf_member_trial
      rescue
        nil
      end
    else
      raise "Unknown target: #{target.inspect}"
    end
  end

  def rjjk_attribute(nkf_attr, mapping)
    if respond_to?(nkf_attr)
      nkf_value = send(nkf_attr)
    else
      logger.debug "Unknown nkf_attr: #{nkf_attr}"
    end

    if (mapped_attribute = mapping[:map_to])
      target, target_attribute = mapped_attribute.to_a[0]
      relation = target_relation(target)
      rjjk_value = relation&.send(target_attribute)
      mapped_rjjk_value = rjjk_attribute_to_nkf(nkf_attr, rjjk_value, nkf_value)
      mapped_nkf_value = nkf_attribute_to_rjjk(target, target_attribute, nkf_value)
    else
      logger.debug "rjjk_attribute: Ignore attribute: #{nkf_attr}: #{nkf_value.inspect}"
    end
    { nkf_attr: nkf_attr, target: target, target_attribute: target_attribute, nkf_value: nkf_value,
      mapped_nkf_value: mapped_nkf_value, rjjk_value: rjjk_value, mapped_rjjk_value: mapped_rjjk_value,
      form_field: mapping[:form_field] }
  end

  def rjjk_attribute_to_nkf(nkf_attr, rjjk_value, nkf_value)
    if rjjk_value.is_a?(Date)
      rjjk_value.strftime('%d.%m.%Y')
    elsif nkf_attr == :kjonn
      rjjk_value ? 'M' : 'K'
    elsif nkf_attr == :rabatt && rjjk_value == 0
      ''
    elsif nkf_attr == :hoyde
      rjjk_value.presence || nkf_value
    elsif nkf_attr == :postnr
      rjjk_value.presence || nkf_value.presence || '9999'
    elsif nkf_attr == :gren_stilart_avd_parti___gren_stilart_avd_parti
      'Jujutsu (Ingen stilartstilknytning)' # '524'
    else
      rjjk_value.to_s
    end
  end

  def nkf_attribute_to_rjjk(target, target_attribute, nkf_value)
    return nkf_value == 0 ? nil : nkf_value if target == :user && target_attribute == :height
    return nkf_value == 9999 ? nil : nkf_value if target == :user && target_attribute == :postal_code
    return nkf_value if nkf_value.is_a?(Integer) || nkf_value.is_a?(Date)

    if /^\s*(?<day>\d{2})\.(?<month>\d{2})\.(?<year>\d{4})\s*$/ =~ nkf_value
      Date.new(year.to_i, month.to_i, day.to_i)
    elsif /Mann|Kvinne/.match?(nkf_value)
      nkf_value == 'Mann'
    elsif nkf_value.blank? && (
          (target =~ /^(billing|guardian_)/ || target_attribute =~ /^guardian_|email|mobile|phone|_on$/) ||
            ((target == :user && User::NILLABLE_FIELDS.include?(target_attribute))))
      nil
    elsif nkf_value.present? && target_attribute.to_s.include?('email')
      nkf_value.downcase
    else
      nkf_value
    end
  end
end
