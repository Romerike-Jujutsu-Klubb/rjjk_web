# frozen_string_literal: true

class TrialAttendance < ActiveRecord::Base
  scope :by_group_id, ->(group_id) {
    where('group_schedules.group_id = ?', group_id)
        .includes(practice: :group_schedule).references(:group_schedules)
  }

  belongs_to :nkf_member_trial
  belongs_to :practice

  validates :nkf_member_trial, :practice, presence: true

  delegate :date, to: :practice
end
