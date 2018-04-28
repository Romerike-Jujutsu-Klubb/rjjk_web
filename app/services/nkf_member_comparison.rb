# frozen_string_literal: true

class NkfMemberComparison
  attr_reader :errors, :member_changes, :members, :new_members, :orphan_members,
      :orphan_nkf_members, :outgoing_changes

  def initialize
    fetch
  end

  def any?
    [@new_members, @member_changes, @errors].any?(&:present?)
  end

  private def fetch
    @orphan_nkf_members = NkfMember.where(member_id: nil).order(:fornavn, :etternavn, :id).to_a
    @orphan_members = NkfMember.find_free_members
    @members = []
    nkf_members = NkfMember.where('member_id IS NOT NULL').order(:fornavn, :etternavn, :id).to_a
    nkf_members.each do |nkfm|
      relation = nkfm.member
      nkf_values = nkfm.converted_attributes
      nkf_values.each do |attribute, nkf_value|
        rjjk_value = relation.send(:"#{attribute}")
        if nkf_value != rjjk_value
          puts "Member (#{'%4d' % relation.id}) #{relation.class} (#{'%4s' % relation.id.inspect}): #{attribute}: #{rjjk_value.inspect} => #{nkf_value.inspect}" # rubocop: disable all
          relation.send(:"#{attribute}=", nkf_value)
        end
      end
      @members << relation if relation.changed?
    end
  end

  def sync
    @errors = []
    create_new_members
    agent, front_page = setup_sync
    sync_members(agent, front_page)
  end

  private def sync_members(agent, front_page)
    @member_changes = @members.map do |m|
      sync_member_with_agent(agent, front_page, m)
    end.compact
  end

  def sync_member(member)
    agent, front_page = setup_sync
    member.attributes = member.nkf_member.converted_attributes
    sync_member_with_agent(agent, front_page, member)
  end

  private

  def create_new_members
    @new_members = @orphan_nkf_members.map do |nkf_member|
      begin
        logger.info "Create member from NKF: #{nkf_member.inspect}"
        nkf_member.create_corresponding_member!
      rescue => e
        logger.error e
        logger.error e.backtrace.join("\n")
        @errors << ['New member', nkf_member, e]
        nil
      end
    end.compact
  end

  private def setup_sync
    @errors = []
    @outgoing_changes = []
    agent = NkfAgent.new
    front_page = agent.login
    [agent, front_page]
  end

  private def sync_member_with_agent(agent, front_page, m)
    logger.info "Synching member: #{m.nkf_member.medlemsnummer} #{m.inspect}"
    logger.info "m.changes: #{m.changes.pretty_inspect}"
    begin
      search_form = front_page.form('ks_reg_medladm') do |search|
        search.p_ks_reg_medladm_action = 'SEARCH'
        search['frm_27_v29'] = 0
        search['frm_27_v40'] = m.nkf_member.medlemsnummer
      end
      search_result = search_form.submit
      edit_link = search_result.css('tr.trList td.tdListData1')[9]
      token = edit_link.attr('onclick')[14..-3]
      member_page = agent.get(<<~URL)
        http://nkfwww.kampsport.no/portal/page/portal/ks_utv/ks_medlprofil?p_cr_par=#{token}
      URL
      outgoing_changes_for_member = {}
      member_form = member_page.form('ks_medlprofil') do |form|
        m.changes.each do |attr, (old_value, new_value)|
          next if old_value.blank? && new_value.blank?
          attr_sym = attr.to_sym
          _nkf_column, nkf_mapping = NkfMember::FIELD_MAP.find do |_k, v|
            [*v[:map_from]].include?(attr_sym) || v[:map_to] == attr_sym
          end
          next if nkf_mapping && nkf_mapping[:import]
          if (nkf_field = nkf_mapping&.fetch(:form_field, nil))
            form_value = old_value.is_a?(Date) ? old_value.strftime('%d.%m.%Y') : old_value # rubocop: disable Style/FormatStringToken
            logger.info "set form value #{nkf_field.inspect} = #{form_value.inspect}"
            form[nkf_field.to_s] = form_value
            outgoing_changes_for_member[attr] = { new_value => old_value }
          else
            @errors << ['Unhandled change', m, attr]
          end
        end
        @outgoing_changes << [m, outgoing_changes_for_member] if outgoing_changes_for_member.any?
      end
      logger.info "outgoing_changes: #{outgoing_changes_for_member}"
      if Rails.env.production? && outgoing_changes_for_member.any?
        m.restore_attributes(outgoing_changes_for_member.keys)
        logger.info 'Submitting form to NKF'
        logger.info member_form.pretty_inspect
        member_form['p_ks_medlprofil_action'] = 'OK'
        member_form.submit
      end
      changes = m.changes
      unless changes.empty?
        m.save!
        [m, changes]
      end
    rescue => e
      logger.error "Exception saving member changes for #{m.attributes.inspect}"
      logger.error e.message
      logger.error e.backtrace.join("\n")
      @errors << ['Changes', m, e]
      nil
    end
  end
end
