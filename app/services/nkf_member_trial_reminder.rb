# frozen_string_literal: true

class NkfMemberTrialReminder
  def self.notify_overdue_trials
    trials = NkfMemberTrial.where('innmeldtdato < ?', 2.months.ago).order(:innmeldtdato).to_a
    trials.group_by(&:group).each do |group, group_trials|
      handler = group&.current_semester&.chief_instructor || Role[:Medlemsansvarlig] || Role[:Kasserer] ||
          Role[:Hovedinstruktør]
      NkfMemberTrialMailer.notify_overdue_trials(handler, group_trials)
          .store(handler, tag: :overdue_trials)
    end
  end
end
