class TrialAttendance < ActiveRecord::Base
  belongs_to :group_schedule

  def date
    Date.commercial(year, week, group_schedule.weekday)
  end

end
