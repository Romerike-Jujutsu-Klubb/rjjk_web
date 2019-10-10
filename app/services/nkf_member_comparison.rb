# frozen_string_literal: true

class NkfMemberComparison
  MEMBER_ERROR_PATTERN =
      %r{<div class=divError id="div_48_v04">\s*<ul class="ulError">(?<message>.*?)</ul>\s*</div>}.freeze

  attr_reader :errors, :member_changes, :members, :new_members, :orphan_members,
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
    [@new_members, @member_changes, @errors].any?(&:present?)
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
    @member_changes = @members.map do |m, changes|
      sync_member_with_agent(agent, front_page, m, changes)
    end.compact
  end

  def create_new_members
    created_members = @orphan_nkf_members.map do |nkf_member|
      logger.info "Create member from NKF: #{nkf_member.inspect}"
      nkf_member.create_corresponding_member!
    rescue => e
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
    form[nkf_field] = mapped_rjjk_value&.encode(form.encoding)
    outgoing_changes[attr_sym] = { nkf_value => mapped_rjjk_value }
  end

  def setup_sync
    @errors = []
    @outgoing_changes = []
    agent = NkfAgent.new
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
    nil
  end

  def submit_changes_to_nkf(agent, front_page, m, mapped_changes)
    member_form, outgoing_changes_for_member = find_outgoing_changes(agent, front_page, m, mapped_changes)
    return unless Rails.env.production? && outgoing_changes_for_member.any?

    logger.info 'Submitting form to NKF'
    member_form['p_ks_medlprofil_action'] = 'OK'
    change_response_page = member_form.submit
    logger.info do
      "change_response_page: code: #{change_response_page.code.inspect}" \
      " encoding: #{change_response_page.encoding.inspect}" \
      "\n#{change_response_page.body}"
    end
    if (m = MEMBER_ERROR_PATTERN.match(change_response_page.body))
      ms = m[:message]
      message = "Error updating NKF member form: #{ms.encode(Encoding::UTF_8, member_form.encoding)}"
      logger.error "message.encoding: #{message.encoding}"
      raise message
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
