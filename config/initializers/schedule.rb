unless Rails.env == 'test'
  scheduler = Rufus::Scheduler.start_new
  scheduler.every('60m', :first_in => '10s') do
    i = NkfMemberImport.new
    NkfReplication.import_changes(i).deliver if i.any?

    errors = []

    c = NkfMemberComparison.new

    new_members = c.orphan_nkf_members.map do |nkf_member|
      nkf_member.create_corresponding_member!
    end

    member_changes = c.members.map do |m|
      begin
        changes = m.changes
        m.save!
        [m, changes] unless changes.empty?
      rescue
        Rails.logger.error "Exception saving member changes"
        Rails.logger.error $!.message
        Rails.logger.error $!.backtrace.join("\n")
        errors << ['Changes', m, $!]
        nil
      end
    end.compact

    group_changes = Hash.new { |h, k| h[k] = [[], []] }
    (new_members + c.members).each do |member|
      nkf_group_names = member.nkf_member.gren_stilart_avd_parti___gren_stilart_avd_parti.split(/ - /).map { |n| n.split('/')[3] }
      member_groups = member.groups.map { |g| g.name }
      (nkf_group_names - member_groups).each do |gn|
        if group = c.groups.find { |g| g.name == gn }
          group = Group.find(group.id)
          member.groups << group
          group_changes[member][0] << group
        end
      end
      (member_groups - nkf_group_names).each do |gn|
        if group = c.groups.find { |g| g.name == gn }
          group = Group.find(group.id)
          member.groups.delete(group)
          group_changes[member][1] << group
        end
      end
    end

    begin
      NkfReplication.update_members(new_members, member_changes, group_changes, errors).deliver if new_members.any? || member_changes.any? || group_changes.any?
    rescue
      Rails.logger.error "Execption sending update_members email"
      Rails.logger.error $!.message
      Rails.logger.error $!.backtrace.join("\n")
    end
  end
end
