class NkfReplication < ActionMailer::Base
  include MailerHelper

  layout 'email'
  default from: Rails.env.production? ? 'noreply@jujutsu.no' : "#{Rails.env}@jujutsu.no",
      to: Rails.env.production? ? %w(medlem@jujutsu.no uwe@kubosch.no) : 'uwe@kubosch.no'

  def import_changes(nkf_member_import)
    @import = nkf_member_import
    mail subject: (@import.exception ? 'Det oppsto en feil ved henting av' :
            "Hentet #{@import.size}") + ' endringer fra NKF'
  end

  def update_members(comparison)
    @new_members = comparison.new_members
    @member_changes = comparison.member_changes
    @group_changes = comparison.group_changes
    @errors = comparison.errors
    stats = [
        @new_members.any? ? "#{@new_members.size} nye" : nil,
        @member_changes.any? ? "#{@member_changes.size} endrede" : nil,
        @group_changes.any? ? "#{@group_changes.size} gruppeendringer" : nil
    ].compact.join(', ')
    mail subject: rjjk_prefix("Oppdateringer fra NKF: #{stats}")
  end

  def update_appointments(appointments)
    @appointments = appointments
    mail subject: rjjk_prefix("Verv fra NKF: #{appointments.size}")
  end

  def wrong_contracts(wrong_contracts)
    @wrong_contracts = wrong_contracts
    mail subject: 'Medlemmer med feil kontrakt'
  end

end
