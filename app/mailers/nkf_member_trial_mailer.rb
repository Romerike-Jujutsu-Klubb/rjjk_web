# encoding: utf-8
class NkfMemberTrialMailer < ActionMailer::Base
  layout 'email'
  default from: Rails.env == 'production' ? 'webmaster@jujutsu.no' : "#{Rails.env}@jujutsu.no",
          to: Rails.env == 'production' ? %w(medlem@jujutsu.no uwe@kubosch.no) : '"medlem@jujutsu.no" <uwe@kubosch.no>'

  def notify_trial_end
    @greeting = 'Hi'
    mail to: 'to@example.org'
  end

  def notify_overdue_trials(trials)
    @trials = trials
    mail subject: 'Utløpt prøvetid'
  end
end
