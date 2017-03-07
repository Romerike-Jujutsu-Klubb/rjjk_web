# frozen_string_literal: true
class NkfMemberComparison
  attr_reader :errors, :group_changes, :members, :member_changes, :new_members,
      :orphan_members, :orphan_nkf_members

  def initialize
    ActiveRecord::Base.transaction do
      fetch
      sync
    end
  end

  def fetch
    @orphan_nkf_members = NkfMember.where(member_id: nil)
        .order(:fornavn, :etternavn).to_a
    @orphan_members = NkfMember.find_free_members
    @members = []
    nkf_members = NkfMember.where('member_id IS NOT NULL')
        .order(:fornavn, :etternavn).to_a
    nkf_members.each do |nkfm|
      member = nkfm.member
      member.attributes = nkfm.converted_attributes
      nkf_group_names =
          if nkfm.gren_stilart_avd_parti___gren_stilart_avd_parti
            nkfm.gren_stilart_avd_parti___gren_stilart_avd_parti
                .split(/ - /).map { |n| n.split('/')[3] || "ERROR: #{n.inspect}" }
          else
            []
          end
      if member.changed? || (nkf_group_names.sort != member.groups.map(&:name).sort)
        @members << nkfm.member
      end
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

    @member_changes = @members.map do |m|
      begin
        changes = m.changes
        m.save!
        [m, changes] unless changes.empty?
      rescue => e
        Rails.logger.error "Exception saving member changes for #{m.attributes.inspect}"
        Rails.logger.error e.message
        Rails.logger.error e.backtrace.join("\n")
        @errors << ['Changes', m, e]
        nil
      end
    end.compact

    @group_changes = Hash.new { |h, k| h[k] = [[], []] }
    (@new_members + @members).each do |member|
      if member.nkf_member.gren_stilart_avd_parti___gren_stilart_avd_parti
        nkf_group_names = member.nkf_member
            .gren_stilart_avd_parti___gren_stilart_avd_parti.split(/ - /)
            .map { |n| n.split('/')[3] }
      else
        logger.error "No groups: #{member.nkf_member.inspect}"
        nkf_group_names = []
      end
      member_groups = member.groups.map(&:name)
      (nkf_group_names - member_groups).each do |gn|
        if (group = Group.find_by(name: gn))
          member.groups << group
          @group_changes[member][0] << group
        end
      end
      (member_groups - nkf_group_names).each do |gn|
        if (group = Group.find_by(name: gn))
          member.groups.delete(group)
          @group_changes[member][1] << group
        end
      end
    end
  end

  def any?
    @new_members.any? || @member_changes.any? || @group_changes.any? ||
        @errors.any?
  end
end
