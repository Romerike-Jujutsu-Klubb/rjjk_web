class NkfMemberTrialReminder
  def self.notify_overdue_trials
    trials = NkfMemberTrial.where('reg_dato < ?', 2.months.ago).order(:reg_dato).all
    NkfMemberTrialMailer.notify_overdue_trials(trials).deliver
  rescue Exception
    logger.error $!
    ExceptionNotifier.notify_exception($!)
  end

  def self.send_waiting_lists
    lists = Group.all.map(&:waiting_list).select(&:any?)
    NkfMemberTrialMailer.send_waiting_lists(lists).deliver
  rescue Exception
    logger.error $!
    ExceptionNotifier.notify_exception($!)
  end
end
