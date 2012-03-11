class NkfMemberComparison
  attr_reader :groups, :members, :orphan_members, :orphan_nkf_members

  def initialize
    @orphan_nkf_members = NkfMember.all(:conditions => 'member_id IS NULL', :order => 'fornavn, etternavn')
    @orphan_members = NkfMember.find_free_members
    @groups = Group.all :order => 'from_age DESC, to_age DESC'
    @members = []
    nkf_members = NkfMember.all :conditions => 'member_id IS NOT NULL', :order => 'fornavn, etternavn'
    nkf_members.each do |nkfm|
      member = nkfm.member
      member.attributes = nkfm.converted_attributes
      nkf_group_names = member.nkf_member.gren_stilart_avd_parti___gren_stilart_avd_parti.split(/ - /).map { |n| n.split('/')[3] }
      if member.changed? || (nkf_group_names.sort != member.groups.map { |g| g.name }.sort)
        @members << nkfm.member
      end
    end
  end

end