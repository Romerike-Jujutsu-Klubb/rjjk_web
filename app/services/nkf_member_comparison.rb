# frozen_string_literal: true

class NkfMemberComparison
  MEMBER_ERROR_PATTERN =
      %r{<div class=divError id="div_48_v04">\s*<ul class="ulError">(?<message>.*?)</ul>\s*</div>}.freeze

  attr_reader :errors, :members, :new_members, :orphan_members,
      :orphan_nkf_members, :outgoing_changes

  def self.target_relation(member, target, nkf_values = {})
    case target
    when :membership
      member
    when :user
      member.user
    when :billing
      if nkf_values.any? { |_k, v| v.present? }
        if nkf_values[:email] && (existing_email_user = User.find_by(email: nkf_values[:email]))
          logger.info "Use existing billing user: #{existing_email_user}"
          member.user.billing_user = existing_email_user
          existing_email_user
        elsif member.user.billing_user
          member.user.billing_user
        else
          logger.info "Create new billing user: #{nkf_values}"
          member.user.build_billing_user
        end
      else
        member.user.billing_user
      end
    when :guardian_1
      member.user.guardian_1 ||
          ((nkf_values.any? { |_k, v| v.present? } || nil) && member.user.build_guardian_1)
    when :guardian_2
      member.user.guardian_2 ||
          ((nkf_values.any? { |_k, v| v.present? } || nil) && member.user.build_guardian_2)
    end
  end

  def initialize(member_id = nil)
    load_changes(member_id)
  end

  def any?
    [@new_members, @outgoing_changes, @errors].any?(&:present?)
  end

  def sync
    agent, front_page = setup_sync
    create_new_members
    sync_members(agent, front_page)
    self
  end

  private

  def load_changes(member_id)
    @orphan_nkf_members = NkfMember.where(member_id: nil).order(:fornavn, :etternavn, :id).to_a
    @orphan_members = NkfMember.find_free_members
    @members = []
    base_query = NkfMember.order(:fornavn, :etternavn, :id)
    query = member_id ? base_query.where(member_id: member_id) : base_query.where.not(member_id: nil)
    query.each do |nkfm|
      member = nkfm.member
      mapped_changes = nkfm.mapping_changes
      @members << [member, mapped_changes] if mapped_changes.any?
    end
  end

  def sync_members(agent, front_page)
    @members.each { |m, changes| sync_member_with_agent(agent, front_page, m, changes) }
  end

  def create_new_members
    created_members = @orphan_nkf_members.map do |nkf_member|
      logger.info "Create member from NKF: #{nkf_member.inspect}"
      nkf_member.create_corresponding_member!
    rescue => e
      logger.error "Exception creating new member: #{e.class}: #{e.message}"
      logger.error e
      logger.error e.backtrace.join("\n")
      @errors << ['New member', e, nkf_member]
      nil
    end
    @new_members = created_members.compact
  end

  def sync_attribute(_membership, form, outgoing_changes, nkf_mapping)
    mapped_rjjk_value = nkf_mapping[:mapped_rjjk_value]
    nkf_value = nkf_mapping[:nkf_value]

    if mapped_rjjk_value.blank? && nkf_value.blank?
      logger.error "No update needed for #{nkf_mapping[:nkf_attr]}"
      return
    end

    attr_sym = { nkf_mapping[:target] => nkf_mapping[:target_attribute] }
    return unless (nkf_field = nkf_mapping[:form_field]&.to_s)

    form_value = form[nkf_field]
    logger.info "Set form field #{nkf_field}: #{form_value.inspect} => #{mapped_rjjk_value.inspect}"
    desired_value = mapped_rjjk_value&.encode(form.encoding)
    form_field = form.field_with(name: nkf_field)
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
      if form_field.name == 'frm_48_v48'
        options_uri = URI('https://nkfwww.kampsport.no/portal/pls/portal/myports.ks_ajax.main')
        http = Net::HTTP.new(options_uri.host, options_uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        options_uri.query = <<~URL
          p_type=4&p_para1=#{desired_option.value}&p_para2=undefined&p_field_id=frm_48_v36&p_first_line_txt=-%20Velg%20sats%20-&p_class_name=inputTextFull
        URL
        request = Net::HTTP::Get.new(options_uri.request_uri)
        response = http.request(request).body
        response_doc = Nokogiri::HTML(response)
        form_field_36 = form.field_with(name: 'frm_48_v36')
        response_options =
            response_doc.css('option').map { |o| Mechanize::Form::Option.new(o, form_field_36) }
        form_field_36.node.replace(response)
        form_field_36.options = response_options

        options_uri.query = <<~URL
          p_type=11&p_para1=#{desired_option.value}&p_para2=undefined&p_field_id=frm_48_v37&p_first_line_txt=-%20Velg%20kontraktstype%20-&p_class_name=inputTextFull
        URL
        request_37 = Net::HTTP::Get.new(options_uri.request_uri)
        response_37 = http.request(request_37).body
        response_doc_37 = Nokogiri::HTML(response_37)
        form_field_37 = form.field_with(name: 'frm_48_v37')
        response_options_37 =
            response_doc_37.css('option').map { |o| Mechanize::Form::Option.new(o, form_field_37) }
        form_field_37.node.replace(response_37)
        form_field_37.options = response_options_37
      end
    else
      form[nkf_field] = desired_value
    end
    outgoing_changes[attr_sym] = { nkf_value => mapped_rjjk_value }
  end

  def setup_sync
    @errors = []
    @outgoing_changes = []
    agent = NkfAgent.new(:comparison)
    front_page = agent.login
    [agent, front_page]
  end

  def sync_member_with_agent(agent, front_page, m, mapped_changes)
    logger.info "Synching member: #{m.user.name} #{m.nkf_member.medlemsnummer} #{m.inspect}"
    logger.info "mapped_changes: #{mapped_changes.pretty_inspect}"
    submit_changes_to_nkf(agent, front_page, m, mapped_changes)
  rescue => e
    logger.error "Exception saving member changes for #{m.attributes.inspect}"
    logger.error e.message
    logger.error e.backtrace.join("\n")
    @errors << ['Changes', e, m]
  end

  def submit_changes_to_nkf(agent, front_page, m, mapped_changes)
    member_form, outgoing_changes_for_member = find_outgoing_changes(agent, front_page, m, mapped_changes)
    return unless Rails.env.production? && outgoing_changes_for_member.any?

    logger.info 'Submitting form to NKF'
    member_form['p_ks_medlprofil_action'] = 'OK'
    change_response_page = member_form.submit
    if (m = MEMBER_ERROR_PATTERN.match(change_response_page.body))
      raise <<~MESSAGE
        Error updating NKF member form:
        #{m[:message].encode(Encoding::UTF_8, member_form.encoding)}
        #{member_form.fields.map { |f| "#{f.name}: #{f.value.inspect}" }.join("\n")}
      MESSAGE
    end

    change_response_page
  end

  def find_outgoing_changes(agent, front_page, membership, mapped_changes)
    search_form = front_page.form('ks_reg_medladm') do |search|
      search.p_ks_reg_medladm_action = 'SEARCH'
      search['frm_27_v29'] = 0
      search['frm_27_v40'] = membership.nkf_member.medlemsnummer
    end
    search_result = search_form.submit
    edit_link = search_result.css('tr.trList td.tdListData1')[9]
    token = edit_link.attr('onclick')[14..-3]
    member_page = agent.get("page/portal/ks_utv/ks_medlprofil?p_cr_par=#{token}")
    outgoing_changes_for_member = {}
    member_form = member_page.form('ks_medlprofil') do |form|
      mapped_changes.each do |mc|
        sync_attribute(membership, form, outgoing_changes_for_member, mc)
      end
      @outgoing_changes << [membership, outgoing_changes_for_member] if outgoing_changes_for_member.any?
    end
    logger.info "outgoing_changes: #{outgoing_changes_for_member}"
    [member_form, outgoing_changes_for_member]
  end
end
