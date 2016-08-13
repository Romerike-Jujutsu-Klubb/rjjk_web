class NkfMemberTrialMailer < ActionMailer::Base
  include MailerHelper
  layout 'email'
  default from: Rails.env == 'production' ? 'noreply@jujutsu.no' : "#{Rails.env}@jujutsu.no",
          to: Rails.env == 'production' ? %w(medlem@jujutsu.no uwe@kubosch.no) : '"medlem@jujutsu.no" <uwe@kubosch.no>'

  def notify_trial_end(trial_member)
    @trial_member = trial_member
    @title = 'Utløpt prøvetid'
    @greeting = 'Hi'
    mail to: 'to@example.org', subject: rjjk_prefix(@title)
  end

  def notify_overdue_trials(recipient, trials)
    @recipient = recipient
    @title = 'Utløpt prøvetid'
    @trials = trials
    mail to: safe_email(recipient), subject: rjjk_prefix(@title)
  end
end
