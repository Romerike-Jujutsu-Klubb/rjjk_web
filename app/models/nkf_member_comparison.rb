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
    @orphan_nkf_members = NkfMember.where('member_id IS NULL').order('fornavn, etternavn').to_a
    @orphan_members = NkfMember.find_free_members
    @members = []
    nkf_members = NkfMember.where('member_id IS NOT NULL').order('fornavn, etternavn').to_a
    nkf_members.each do |nkfm|
      member = nkfm.member
      member.attributes = nkfm.converted_attributes
      nkf_group_names = member.nkf_member.gren_stilart_avd_parti___gren_stilart_avd_parti.split(/ - /).map { |n| n.split('/')[3] }
      if member.changed? || (nkf_group_names.sort != member.groups.map { |g| g.name }.sort)
        @members << nkfm.member
      end
    end
  end

  def sync
    @errors = []

    @new_members = @orphan_nkf_members.map do |nkf_member|
      nkf_member.create_corresponding_member!
    end

    @member_changes = @members.map do |m|
      begin
        changes = m.changes
        m.save!
        [m, changes] unless changes.empty?
      rescue
        Rails.logger.error "Exception saving member changes for #{m.attributes.inspect}"
        Rails.logger.error $!.message
        Rails.logger.error $!.backtrace.join("\n")
        @errors << ['Changes', m, $!]
        nil
      end
    end.compact

    @group_changes = Hash.new { |h, k| h[k] = [[], []] }
    (@new_members + @members).each do |member|
      nkf_group_names = member.nkf_member.gren_stilart_avd_parti___gren_stilart_avd_parti.split(/ - /).map { |n| n.split('/')[3] }
      member_groups = member.groups.map { |g| g.name }
      (nkf_group_names - member_groups).each do |gn|
        if (group = Group.find_by_name(gn))
          member.groups << group
          @group_changes[member][0] << group
        end
      end
      (member_groups - nkf_group_names).each do |gn|
        if (group = Group.find_by_name(gn))
          member.groups.delete(group)
          @group_changes[member][1] << group
        end
      end
    end
  end

  def any?
    @new_members.any? || @member_changes.any? || @group_changes.any?
  end

end
