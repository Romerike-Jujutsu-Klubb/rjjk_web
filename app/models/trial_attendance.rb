class TrialAttendance < ActiveRecord::Base
  scope :by_group_id, -> (group_id) { where('group_schedules.group_id = ?', group_id).includes(practice: :group_schedule).references(:group_schedules) }

  belongs_to :nkf_member_trial
  belongs_to :practice

  validates_presence_of :nkf_member_trial, :practice

  def date
    practice.date
  end
end
