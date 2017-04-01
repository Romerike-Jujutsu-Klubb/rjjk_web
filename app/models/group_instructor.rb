# frozen_string_literal: true

class GroupInstructor < ActiveRecord::Base
  module Role
    CHIEF = 'Hovedinstruktør'
    INSTRUCTOR = 'Instruktør'
    ASSISTANT = 'Hjelpeinstruktør'
  end

  belongs_to :group_schedule
  belongs_to :group_semester
  belongs_to :member

  scope :active, ->(date = Date.current) do
    includes(group_semester: :semester)
        .references(:semesters)
        .where('semesters.start_on <= :date AND semesters.end_on >= :date',
            date: date)
  end

  validates :group_schedule_id, :member_id, :group_semester_id, presence: true
  validates :group_schedule, presence: { if: :group_schedule_id }
  validates :group_semester, presence: { if: :group_semester_id }
  validates :member, presence: { if: :member_id }
  validates :member_id, uniqueness: { scope: %i(group_schedule_id group_semester_id) }

  validate do
    if group_semester && group_schedule && group_semester.group_id != group_schedule.group_id
      errors.add :group_semester, 'må være likt som gruppe-tiden'
    end
    errors.add :semester_id, 'må velges' if group_semester_id.blank?
  end

  def active?(date = Date.current)
    group_semester.semester.start_on <= date && (group_semester.semester.end_on >= date)
  end

  def role
    if group_semester.chief_instructor_id == member_id
      Role::CHIEF
    elsif assistant?
      Role::ASSISTANT
    else
      Role::INSTRUCTOR
    end
  end
end
