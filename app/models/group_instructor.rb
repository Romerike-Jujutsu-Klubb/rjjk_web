class GroupInstructor < ActiveRecord::Base
  attr_accessible :group_schedule, :group_schedule_id, :member_id, :role, :semester_id

  module Role
    CHIEF = 'Hovedinstruktør'
    INSTRUCTOR = 'Instruktør'
    ASSISTANT = 'Hjelpeinstruktør'
  end

  belongs_to :group_schedule
  belongs_to :member
  belongs_to :semester

  validates_presence_of :group_schedule, :group_schedule_id, :member, :member_id, :semester, :semester_id

  validates_uniqueness_of :member_id, :scope => [:group_schedule_id, :semester_id]

  def active?(date = Date.today)
    semester.start_on <= date && (semester.end_on >= date)
  end

end
