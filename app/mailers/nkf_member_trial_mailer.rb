# frozen_string_literal: true
class NkfMemberTrialMailer < ActionMailer::Base
  include MailerHelper

  default from: noreply_address,
          to: Rails.env == 'production' ? %w(medlem@jujutsu.no uwe@kubosch.no) : '"medlem@jujutsu.no" <uwe@kubosch.no>'

  def notify_trial_end(trial_member)
    @trial_member = trial_member
    @title = 'Utløpt prøvetid'
    @greeting = 'Hi'
    mail to: 'to@example.org', subject: @title
  end

  def notify_overdue_trials(recipient, trials)
    @recipient = recipient
    @title = 'Utløpt prøvetid'
    @trials = trials
    mail to: recipient.email, subject: @title
  end
end
