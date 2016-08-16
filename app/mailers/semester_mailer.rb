class SemesterMailer < ActionMailer::Base
  include MailerHelper

  default from: noreply_address, to: 'uwe@kubosch.no', bcc: 'uwe@kubosch.no'

  def missing_current_semester(recipient)
    @recipient = recipient
    mail to: recipient.email, subject: 'Planlegge semesteret'
  end

  def missing_next_semester(recipient)
    @recipient = recipient
    mail to: recipient.email, subject: 'Planlegge neste semester'
  end

  def missing_session_dates(recipient, group)
    @recipient = recipient
    @group = group
    mail to: recipient.email, subject: 'Planlegge neste semester'
  end
end
