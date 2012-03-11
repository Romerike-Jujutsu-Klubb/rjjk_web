scheduler = Rufus::Scheduler.start_new
scheduler.every('60m', :first_in => '10s') do
  i = NkfMemberImport.new
  NkfReplication.import_changes(i).deliver if i.any?

  c = NkfMemberComparison.new

  c.orphan_nkf_members.each do |nkf_member|
    nkf_member.create_member!
  end

  c.members.each do |m|
    m.save!
  end

  c.members.each do |member|
    nkf_group_names = member.nkf_member.gren_stilart_avd_parti___gren_stilart_avd_parti.split(/ - /).map { |n| n.split('/')[3] }
    member_groups = member.groups.map { |g| g.name }
    (nkf_group_names - member_groups).each do |gn|
      if group = c.groups.find { |g| g.name == gn }
        @member.groups << Group.find(group.id)
      end
    end
  end

  NkfReplication.update_members(c).deliver if c.orphan_nkf_members.any? || c.members.any?
end
