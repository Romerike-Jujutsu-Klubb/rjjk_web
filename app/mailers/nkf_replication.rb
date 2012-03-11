class NkfReplication < ActionMailer::Base
  default from: "uwe@kubosch.no"

  def import_changes(nkf_member_import)
    @import = nkf_member_import

    mail to: "uwe@kubosch.no", :subject => "Hentet #{@import.size} endringer fra NKF"
  end

  def synchronize
    @greeting = "Hi"

    mail to: "uwe@kubosch.no"
  end
end
