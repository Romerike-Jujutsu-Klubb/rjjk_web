class TrialAttendance < ActiveRecord::Base
  named_scope :by_group_id, lambda { |group_id| { :conditions => ['group_schedules.group_id = ?', group_id], :include => :group_schedule }}

  belongs_to :group_schedule

  def date
    Date.commercial(year, week, group_schedule.weekday)
  end

end
