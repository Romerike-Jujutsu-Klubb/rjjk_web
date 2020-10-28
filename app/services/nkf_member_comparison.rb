# frozen_string_literal: true

class NkfMemberComparison
  include NkfForm

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
    outgoing_changes_for_member = submit_changes_to_nkf(agent, front_page, m, mapped_changes, :member)
    @outgoing_changes << [m, outgoing_changes_for_member] if outgoing_changes_for_member.any?
  rescue => e
    logger.error "Exception saving member changes for #{m.attributes.inspect}"
    logger.error e.message
    logger.error e.backtrace.join("\n")
    @errors << ['Changes', e, m]
  end
end
