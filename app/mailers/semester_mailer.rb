class SemesterMailer < ActionMailer::Base
  include MailerHelper
  layout 'email'
  default from: Rails.env == 'production' ? 'noreply@jujutsu.no' : "#{Rails.env}@jujutsu.no",
          to: 'uwe@kubosch.no', bcc: 'uwe@kubosch.no'

  def missing_current_semester(recipient)
    @recipient = recipient
    mail to: safe_email(recipient), subject: rjjk_prefix('Planlegge semesteret')
  end

  def missing_next_semester(recipient)
    @recipient = recipient
    mail to: safe_email(recipient), subject: rjjk_prefix('Planlegge neste semester')
  end

  def missing_session_dates(recipient, group)
    @recipient = recipient
    @group = group
    mail to: safe_email(recipient), subject: rjjk_prefix('Planlegge neste semester')
  end
end
