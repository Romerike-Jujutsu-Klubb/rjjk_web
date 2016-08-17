# frozen_string_literal: true
class NkfMemberTrialReminder
  def self.notify_overdue_trials
    trials = NkfMemberTrial.where('reg_dato < ?', 2.months.ago).order(:reg_dato).to_a
    trials.group_by(&:group).each do |group, group_trials|
      handler = group.current_semester.chief_instructor || Role[:Kasserer]
      NkfMemberTrialMailer.notify_overdue_trials(handler, group_trials)
          .store(handler, tag: :overdue_trials)
    end
  end
end
