class NkfMemberTrialReminder
  def self.notify_overdue_trials
    trials = NkfMemberTrial.where('reg_dato < ?', 2.months.ago).order(:reg_dato).to_a
    NkfMemberTrialMailer.notify_overdue_trials(trials).deliver_now
  rescue Exception
    logger.error $!
    ExceptionNotifier.notify_exception($!)
  end

  def self.send_waiting_lists
    lists = Group.includes(:members).map(&:waiting_list).select(&:any?)
    return if lists.empty?
    NkfMemberTrialMailer.send_waiting_lists(lists).deliver_now
  rescue Exception
    logger.error $!
    ExceptionNotifier.notify_exception($!)
  end
end
