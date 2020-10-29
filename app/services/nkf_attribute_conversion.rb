# frozen_string_literal: true

# Mix into User
module NkfAttributeConversion
  # `map_to` is used to set a new value in the RJJK model.
  FIELD_MAP = {
    adresse_1: {},
    adresse_2: { map_to: { user: :address }, form_field: { member: :frm_48_v05 } },
    adresse_3: {},
    antall_etiketter_1: {},
    betalt_t_o_m__dato: {},
    created_at: {},
    epost: { map_to: { user: :contact_email },
             form_field: { member: :frm_48_v10, new_trial: :frm_29_v10 } },
    epost_faktura: { map_to: { billing: :email }, form_field: { member: :frm_48_v22 } },
    etternavn: { map_to: { user: :last_name },
                 form_field: { member: :frm_48_v04, new_trial: :frm_29_v04 } },
    fodselsdato: { map_to: { user: :birthdate },
                   form_field: { member: :frm_48_v08, new_trial: :frm_29_v08 } },
    foresatte: { map_to: { user: :guardian_1_or_billing_name }, form_field: { member: :frm_48_v23 } },
    foresatte_epost: { map_to: { guardian_1: :email }, form_field: { member: :frm_48_v73 } },
    foresatte_mobil: { map_to: { guardian_1: :phone }, form_field: { member: :frm_48_v74 } },
    foresatte_nr_2: { map_to: { guardian_2: :name }, form_field: { member: :frm_48_v72 } },
    foresatte_nr_2_mobil: { map_to: { guardian_2: :phone }, form_field: { member: :frm_48_v75 } },
    fornavn: { map_to: { user: :first_name },
               form_field: { member: :frm_48_v03, new_trial: :frm_29_v03, trial: :frm_28_v08 } },
    # 524 : Jujutsu (Ingen stilartstilknytning)
    gren_stilart_avd_parti___gren_stilart_avd_parti: { form_field: { new_trial: :frm_29_v16 } },
    hovedmedlem_id: {},
    hovedmedlem_navn: {},
    hoyde: { map_to: { user: :height }, form_field: { member: :frm_48_v13, new_trial: :frm_29_v13 } },
    id: {},
    innmeldtarsak: {},
    innmeldtdato: { map_to: { membership: :joined_on }, form_field: { member: :frm_48_v45 } },
    kjonn: { map_to: { user: :male },
             form_field: { member: :frm_48_v112, new_trial: :frm_29_v11 },
             values: { true => 'M', false => 'K' } },
    klubb: {},
    klubb_id: {},
    konkurranseomrade_id: {},
    konkurranseomrade_navn: {},
    kont_belop: {}, # FIXME(uwe): Map payment values
    kont_sats: { map_to: { membership: :category }, form_field: { member: :frm_48_v36 } },
    kontraktsbelop: { map_to: { membership: :monthly_fee } },
    kontraktstype: { map_to: { membership: :contract }, form_field: { member: :frm_48_v37 } },
    medlemskategori: {},
    medlemskategori_navn: { map_to: { membership: :category }, form_field: { member: :frm_48_v48 } },
    medlemsnummer: {},
    medlemsstatus: {}, # FIXME(uwe): Should be mapped: passive_from+left_on => 'A', 'P'
    member_id: {},
    mobil: { map_to: { user: :phone }, form_field: { member: :frm_48_v20 } },
    postnr: { map_to: { user: :postal_code },
              form_field: { member: :frm_48_v07, new_trial: :frm_29_v07 } },
    rabatt: { map_to: { membership: :discount }, form_field: { member: :frm_48_v38 } },
    sist_betalt_dato: {},
    sted: {},
    telefon: { map_to: { membership: :phone_home }, form_field: { member: :frm_48_v19 } },
    telefon_arbeid: { map_to: { membership: :phone_work }, form_field: { member: :frm_48_v21 } },
    updated_at: {},
    utmeldtarsak: {},
    utmeldtdato: { map_to: { membership: :left_on }, form_field: { member: :frm_48_v46 } },
    ventekid: {},
    yrke: {},
  }.freeze

  MAPPED_FIELDS = FIELD_MAP.select { |_nkf_attr, mapping| mapping[:map_to] }.freeze

  def mapping_attributes
    MAPPED_FIELDS.map(&method(:rjjk_attribute)).compact
  end

  def mapping_changes
    mapping_attributes.select do |a|
      next if utmeldtdato.present? && a[:nkf_attr] != :utmeldtdato

      a[:target] && a[:mapped_rjjk_value] != a[:nkf_value]
    end
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
      rjjk_value ? 'Mann' : 'Kvinne'
    elsif nkf_attr == :rabatt && rjjk_value == 0
      ''
    elsif nkf_attr == :hoyde
      rjjk_value.presence || nkf_value
    else
      rjjk_value.to_s
    end
  end

  def nkf_attribute_to_rjjk(target, target_attribute, nkf_value)
    if nkf_value.is_a?(Integer)
      nkf_value
    elsif /^\s*(?<day>\d{2})\.(?<month>\d{2})\.(?<year>\d{4})\s*$/ =~ nkf_value
      Date.new(year.to_i, month.to_i, day.to_i)
    elsif /Mann|Kvinne/.match?(nkf_value)
      nkf_value == 'Mann'
    elsif nkf_value.blank? && (target =~ /^(billing|guardian_)/ ||
        target_attribute =~ /^guardian_|email|mobile|phone|_on$/)
      nil
    elsif nkf_value.blank? && (target == :user && User::NILLABLE_FIELDS.include?(target_attribute))
      nil
    elsif nkf_value.present? && target_attribute.to_s.include?('email')
      nkf_value.downcase
    else
      nkf_value
    end
  end
end
