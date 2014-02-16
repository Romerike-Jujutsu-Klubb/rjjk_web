class GroupInstructor < ActiveRecord::Base
  attr_accessible :group_schedule, :group_schedule_id, :group_semester_id, :member_id, :role

  module Role
    CHIEF = 'Hovedinstruktør'
    INSTRUCTOR = 'Instruktør'
    ASSISTANT = 'Hjelpeinstruktør'
  end

  belongs_to :group_schedule
  belongs_to :group_semester
  belongs_to :member

  scope :active,
      ->(date = Date.today) { includes(:group_semester => :semester).
          where('semesters.start_on <= :date AND semesters.end_on >= :date',
          :date => date) }

  validates_presence_of :group_schedule, :group_schedule_id, :member, :member_id, :group_semester, :group_semester_id

  validates_uniqueness_of :member_id, :scope => [:group_schedule_id, :group_semester_id]

  def active?(date = Date.today)
    group_semester.semester.start_on <= date && (group_semester.semester.end_on >= date)
  end

end
