# frozen_string_literal: true

class NkfMemberTrialMailer < ApplicationMailer
  default to: %w[medlem@jujutsu.no uwe@kubosch.no]

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
