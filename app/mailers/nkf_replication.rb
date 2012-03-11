class NkfReplication < ActionMailer::Base
  default from: 'webmaster@jujutsu.no',
          to: Rails.env == 'prodution' ? ['medlem@jujutsu.no', 'uwe@kubosch.no'] : 'uwe@kubosch.no'

  def import_changes(nkf_member_import)
    @import = nkf_member_import

    mail subject: "Hentet #{@import.size} endringer fra NKF"
  end

  def update_members(new_members, member_changes, group_changes)
    @new_members = new_members
    @member_changes = member_changes
    @group_changes = group_changes
    stats = [
        @new_members.any? ? "#{@new_members.size} nye" : nil,
        @member_changes.any? ? "#{@member_changes.size} endrede" : nil,
        @group_changes.any? ? "#{@group_changes.size} gruppeendringer" : nil
    ].compact.join(', ')
    mail subject: "Oppdateringer fra NKF: #{stats}"
  end
end
