# frozen_string_literal: true

class NkfMemberComparison
  attr_reader :errors, :member_changes, :members, :new_members, :orphan_members,
      :orphan_nkf_members, :outgoing_changes

  def initialize
    fetch
  end

  def any?
    @new_members.any? || @member_changes.any? || @errors.any?
  end

  private def fetch
    @orphan_nkf_members = NkfMember.where(member_id: nil).order(:fornavn, :etternavn).to_a
    @orphan_members = NkfMember.find_free_members
    @members = []
    nkf_members = NkfMember.where('member_id IS NOT NULL').order(:fornavn, :etternavn).to_a
    nkf_members.each do |nkfm|
      member = nkfm.member
      member.attributes = nkfm.converted_attributes
      @members << nkfm.member if member.changed?
    end
  end

  def sync
    @errors = []

    @new_members = @orphan_nkf_members.map do |nkf_member|
      begin
        nkf_member.create_corresponding_member!
      rescue => e
        logger.error e
        logger.error e.backtrace.join("\n")
        @errors << ['New member', nkf_member, e]
        nil
      end
    end.compact

    sync_members
  end

  private

  def sync_members
    @outgoing_changes = []
    agent = NkfAgent.new
    front_page = agent.login

    @member_changes = @members.map do |m|
      begin
        search_result = front_page.form('ks_reg_medladm') do |search|
          search.p_ks_reg_medladm_action = 'SEARCH'
          search.add_field!('frm_27_v29', 0)
          search.add_field!('frm_27_v40', m.nkf_member.medlemsnummer)
        end.submit
        edit_link = search_result.css('tr.trList td.tdListData1')[9]
        token = edit_link.attr('onclick')[14..-3]
        member_page = agent.get(<<~URL)
          http://nkfwww.kampsport.no/portal/page/portal/ks_utv/ks_medlprofil?p_cr_par=#{token}
        URL

        outgoing_changes_for_member = {}
        member_form = member_page.form('ks_medlprofil') do |form|
          m.changes.each do |attr, (old_value, new_value)|
            attr_sym = attr.to_sym
            _nkf_column, nkf_mapping = NkfMember::FIELD_MAP.find { |_k, v| v[:map_to] == attr_sym }
            if (nkf_field = nkf_mapping&.fetch(:form_field, nil))
              form_value = old_value.is_a?(Date) ? old_value.strftime('%d.%m.%Y') : old_value
              form[nkf_field.to_s] = form_value
              outgoing_changes_for_member[attr] = { new_value => old_value }
            else
              @errors << ['Unhandled change', m, attr]
            end
          end
          @outgoing_changes << [m, outgoing_changes_for_member] if outgoing_changes_for_member.any?
        end

        if Rails.env.production?
          m.restore_attributes(outgoing_changes_for_member.keys)
          member_form.submit
        end

        changes = m.changes
        unless changes.empty?
          m.save!
          [m, changes]
        end
      rescue => e
        Rails.logger.error "Exception saving member changes for #{m.attributes.inspect}"
        Rails.logger.error e.message
        Rails.logger.error e.backtrace.join("\n")
        @errors << ['Changes', m, e]
        nil
      end
    end.compact
  end
end
