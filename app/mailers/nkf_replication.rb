class NkfReplication < ActionMailer::Base
  default from: "uwe@kubosch.no"

  def import_changes(nkf_member_import)
    @import = nkf_member_import

    mail to: "uwe@kubosch.no", :subject => "Hentet #{@import.size} endringer fra NKF"
  end

  def update_members(nkf_member_comparison)
    @comparison = nkf_member_comparison

    mail to: "uwe@kubosch.no", :subject => "Oppdateringer fra NKF"
  end
end
