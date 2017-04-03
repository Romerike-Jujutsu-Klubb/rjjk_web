# frozen_string_literal: true

class SemesterMailer < ApplicationMailer
  default to: 'uwe@kubosch.no', bcc: 'uwe@kubosch.no'

  def missing_session_dates(recipient, group)
    @recipient = recipient
    @group = group
    mail to: recipient.email, subject: 'Planlegge neste semester'
  end
end
