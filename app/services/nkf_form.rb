# frozen_string_literal: true

module NkfForm
  MEMBER_ERROR_PATTERN = %r{<ul class="ulError">(?<message>.*?)</ul>}m.freeze

  private

  def read_attribute(form, nkf_attr, nkf_mapping, form_key)
    nkf_field = nkf_mapping.dig(:form_field, form_key)&.to_s
    unless nkf_field
      logger.info "Missing form field: #{form_key}: :#{nkf_attr}"
      return
    end
    field_node = form.page.css("##{nkf_field}")[0]
    if field_node.name == 'select'
      form_field = Mechanize::Form::SelectList.new(field_node)
      selected_option = form_field.selected_options.first
      if selected_option
        form_value = if /^\d+$/.match?(selected_option.value)
                       selected_option.text
                     else
                       selected_option.value
                     end
      else
        logger.info "No selected option found in #{form_field.options.map(&:text).inspect}"
      end
    else
      form_value = field_node.attr('value')
    end

    [nkf_attr, form_value]
  end

  def sync_attribute(form, outgoing_changes, nkf_mapping, form_key)
    mapped_rjjk_value = nkf_mapping[:mapped_rjjk_value]
    return unless (nkf_field = nkf_mapping.dig(:form_field, form_key)&.to_s)

    form_field = form.page.css("##{nkf_field}")
    form_value = form_field.attr('value')&.value
    nkf_value = nkf_mapping[:nkf_value]
    if nkf_value != form_value
      logger.info "Updated NKF value: #{nkf_value.inspect} => #{form_value.inspect}"
      nkf_value = form_value
    end
    if mapped_rjjk_value.blank? && nkf_value.blank?
      logger.error "No update needed for #{nkf_mapping[:nkf_attr]}"
      return
    end

    logger.info "Set form field #{nkf_field}: #{form_value.inspect} => #{mapped_rjjk_value.inspect}"
    desired_value = mapped_rjjk_value&.to_s&.encode(form.encoding)
    if form_field.is_a?(Mechanize::Form::SelectList)
      desired_option = form_field.options.find { |o| o.text.strip == desired_value }
      unless desired_option
        raise "Option #{desired_value.inspect} not found in #{form_field.options.map(&:text).inspect}"
      end

      if form_value == desired_option.value
        logger.info <<~LINE
          Set form field #{form_field.name}: #{form_value.inspect} => #{desired_option.value.inspect}: Unchanged
        LINE
        return
      end
      logger.info <<~LINE
        Set form field #{form_field.name}: #{form_value.inspect} => #{desired_option.value.inspect}
      LINE
      desired_option.select
      if nkf_mapping[:nkf_attr] == :medlemskategori_navn
        fee_form_field = NkfMember::FIELD_MAP[:kont_sats][:form_field][form_key]
        options_uri = URI('https://nkfwww.kampsport.no/portal/pls/portal/myports.ks_ajax.main')
        http = Net::HTTP.new(options_uri.host, options_uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        options_uri.query = <<~URL
          p_type=4&p_para1=#{desired_option.value}&p_para2=undefined&p_field_id=#{fee_form_field}&p_first_line_txt=-%20Velg%20sats%20-&p_class_name=inputTextFull
        URL
        request = Net::HTTP::Get.new(options_uri.request_uri)
        response = http.request(request).body
        response_doc = Nokogiri::HTML(response)
        form_field_36 = form.field_with(name: fee_form_field.to_s)
        response_options =
            response_doc.css('option').map { |o| Mechanize::Form::Option.new(o, form_field_36) }
        form_field_36.node.replace(response)
        form_field_36.options = response_options

        contract_form_field = NkfMember::FIELD_MAP[:kontraktstype][:form_field][form_key]
        options_uri.query = <<~URL
          p_type=11&p_para1=#{desired_option.value}&p_para2=undefined&p_field_id=#{contract_form_field}&p_first_line_txt=-%20Velg%20kontraktstype%20-&p_class_name=inputTextFull
        URL
        request_37 = Net::HTTP::Get.new(options_uri.request_uri)
        response_37 = http.request(request_37).body
        response_doc_37 = Nokogiri::HTML(response_37)
        form_field_37 = form.field_with(name: contract_form_field.to_s)
        response_options_37 =
            response_doc_37.css('option').map { |o| Mechanize::Form::Option.new(o, form_field_37) }
        form_field_37.node.replace(response_37)
        form_field_37.options = response_options_37
      end
    else
      form[nkf_field] = desired_value
    end
    attr_sym = { nkf_mapping[:target] => nkf_mapping[:target_attribute] }
    outgoing_changes[attr_sym] = { nkf_value => mapped_rjjk_value }
  end

  def submit_changes_to_nkf(agent, front_page, membership, mapped_changes, form_key)
    search_result = find_member_form_page(front_page, membership)
    edit_link = search_result.css('tr.trList td.tdListData1')[9]
    token = edit_link.attr('onclick')[14..-3]
    member_page = agent.get("page/portal/ks_utv/ks_medlprofil?p_cr_par=#{token}")
    submit_form(member_page, 'ks_medlprofil', mapped_changes, form_key)
  end

  def submit_form(page, form_name, mapped_changes, form_key, submit_in_development: false)
    form = page.form(form_name)
    outgoing_changes_for_member = synchronize_form(mapped_changes, form, form_key)
    if outgoing_changes_for_member.any? && (Rails.env.production? || submit_in_development)
      logger.info 'Submitting form to NKF'
      form["p_#{form_name}_action"] = 'OK'
      change_response_page = form.submit
      if (m = MEMBER_ERROR_PATTERN.match(change_response_page.body))
        raise <<~MESSAGE
          Error updating NKF member form:
          #{m[:message].encode(Encoding::UTF_8, form.encoding)}
          #{form.fields.map { |f| "#{f.name}: #{f.value.inspect}" }.join("\n")}
        MESSAGE
      end
    end
    outgoing_changes_for_member
  end

  def synchronize_form(mapped_changes, form, form_key)
    outgoing_changes_for_member = {}
    mapped_changes.each do |mapped_change|
      parent_change = mapped_change
      while (parent_key = NkfAttributeConversion::MAPPED_FIELDS[parent_change[:nkf_attr]][:depends])
        parent_change = mapped_changes.find { |mc| mc[:nkf_attr] == parent_key }
        sync_attribute(form, outgoing_changes_for_member, parent_change, form_key)
      end
      sync_attribute(form, outgoing_changes_for_member, mapped_change, form_key)
    end
    logger.info "outgoing_changes: #{outgoing_changes_for_member}"
    outgoing_changes_for_member
  end

  def read_form(form, form_key)
    form_values = NkfAttributeConversion::MAPPED_FIELDS.map do |nkf_attr, mapping|
      read_attribute(form, nkf_attr, mapping, form_key)
    end
    Hash[form_values.compact]
  end

  def find_member_form_page(front_page, membership)
    search_form = front_page.form('ks_reg_medladm')
    search_form.p_ks_reg_medladm_action = 'SEARCH'
    search_form['frm_27_v29'] = 0
    search_form['frm_27_v40'] = membership.nkf_member.medlemsnummer
    search_form.submit
  end
end
