class GroupSemester < ActiveRecord::Base
  attr_accessible :first_session, :group_id, :last_session, :semester_id

  belongs_to :chief_instructor, :class_name => :Member
  belongs_to :group
  belongs_to :semester
  has_many :group_instructors, :dependent => :destroy

  validates_presence_of :group, :group_id, :semester, :semester_id

  validate do
    if semester
      if first_session && !(semester.start_on..semester.end_on).include?(first_session)
        errors.add :first_session, 'må være innenfor det tilhørende semesteret.'
      end
      if last_session && !(semester.start_on..semester.end_on).include?(last_session)
        errors.add :last_session, 'må være innenfor det tilhørende semesteret.'
      end
    end
  end

end
