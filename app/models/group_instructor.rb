class GroupInstructor < ActiveRecord::Base
  module Role
    CHIEF = 'Hovedinstruktør'
    INSTRUCTOR = 'Instruktør'
    ASSISTANT = 'Hjelpeinstruktør'
  end

  belongs_to :group_schedule
  belongs_to :group_semester
  belongs_to :member

  scope :active, ->(date = Date.today) do
    includes(group_semester: :semester).
        references(:semesters).
        where('semesters.start_on <= :date AND semesters.end_on >= :date',
            date: date)
  end

  validates_presence_of :group_schedule, :group_schedule_id, :member,
      :member_id, :group_semester_id
  validates_presence_of :group_semester, if: :group_semester_id
  validates_uniqueness_of :member_id, scope: [:group_schedule_id, :group_semester_id]

  validate do
    if group_semester && group_schedule && group_semester.group_id != group_schedule.group_id
      errors.add :group_semester, 'må være likt som gruppe-tiden'
    end
  end

  def active?(date = Date.today)
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
