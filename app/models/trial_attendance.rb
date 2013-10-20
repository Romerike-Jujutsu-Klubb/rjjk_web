class TrialAttendance < ActiveRecord::Base
  scope :by_group_id, lambda { |group_id| where('group_schedules.group_id = ?', group_id).includes(:practice => :group_schedule)}

  belongs_to :nkf_member_trial
  belongs_to :practice

  validates_presence_of :practice, :nkf_member_trial

  def date
    Date.commercial(year, week, group_schedule.weekday)
  end

end
