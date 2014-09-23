# encoding: utf-8
class GroupSemester < ActiveRecord::Base
  belongs_to :chief_instructor, class_name: :Member
  belongs_to :group
  belongs_to :semester
  has_many :group_instructors, dependent: :destroy

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

  def name
    "#{semester.name} - #{group.name}"
  end

  def practices
    return [] unless first_session && last_session
    q = Practice.where('group_schedule_id IN (?)', group.group_schedules.map(&:id))
    q = q.where('year > ? OR (year = ? and week >= ?)', first_session.year, first_session.year, first_session.cweek)
    q = q.where('year < ? OR (year = ? and week <= ?)', last_session.year, last_session.year, last_session.cweek)
    q
  end

end
