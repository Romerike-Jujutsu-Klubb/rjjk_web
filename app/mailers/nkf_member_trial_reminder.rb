class NkfMemberTrialReminder
  def self.notify_overdue_trials
    trials = NkfMemberTrial.where('reg_dato < ?', 2.months.ago).order(:reg_dato).to_a
    NkfMemberTrialMailer.notify_overdue_trials(trials).deliver_now
  rescue Exception
    logger.error $!
    ExceptionNotifier.notify_exception($!)
  end
end
