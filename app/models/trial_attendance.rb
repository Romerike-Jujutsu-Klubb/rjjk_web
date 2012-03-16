class TrialAttendance < ActiveRecord::Base
  scope :by_group_id, lambda { |group_id| { :conditions => ['group_schedules.group_id = ?', group_id], :include => :group_schedule }}

  belongs_to :nkf_member_trial
  belongs_to :group_schedule

  validates_presence_of :group_schedule, :nkf_member_trial, :week, :year

  def date
    Date.commercial(year, week, group_schedule.weekday)
  end

end
