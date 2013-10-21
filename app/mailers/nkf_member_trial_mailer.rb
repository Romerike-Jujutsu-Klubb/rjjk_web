# encoding: utf-8
class NkfMemberTrialMailer < ActionMailer::Base
  include MailerHelper
  layout 'email'
  default from: Rails.env == 'production' ? 'webmaster@jujutsu.no' : "#{Rails.env}@jujutsu.no",
          to: Rails.env == 'production' ? %w(medlem@jujutsu.no uwe@kubosch.no) : '"medlem@jujutsu.no" <uwe@kubosch.no>'

  def notify_trial_end
    @greeting = 'Hi'
    mail to: 'to@example.org'
  end

  def notify_overdue_trials(trials)
    @trials = trials
    mail subject: "#{rjjk_prefix} Utløpt prøvetid"
  end

  def send_waiting_lists(lists)
    @lists = lists
    mail subject: "#{rjjk_prefix} Ventelister"
  end
end
