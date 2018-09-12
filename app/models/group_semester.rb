# frozen_string_literal: true

class GroupSemester < ApplicationRecord
  belongs_to :chief_instructor, class_name: :Member, required: false
  belongs_to :group
  belongs_to :semester

  has_many :group_instructors, dependent: :destroy

  scope :for_date, ->(date = Date.current) do
    joins(:semester).where('? BETWEEN semesters.start_on AND semesters.end_on', date)
  end

  validates :group, :group_id, :semester, :semester_id, presence: true

  validate do
    if semester
      if first_session && !(semester.start_on..semester.end_on).cover?(first_session)
        errors.add :first_session, 'må være innenfor det tilhørende semesteret.'
      end
      if last_session && !(semester.start_on..semester.end_on).cover?(last_session)
        errors.add :last_session, 'må være innenfor det tilhørende semesteret.'
      end
    end
  end

  def self.create_missing_group_semesters
    groups = Group.active.all
    Semester.all.find_each do |s|
      groups.each do |g|
        GroupSemester.where(group_id: g.id, semester_id: s.id).first_or_create!
      end
    end
  end

  def name
    "#{semester.name} - #{group.name}"
  end

  def practices
    return [] unless first_session && last_session

    q = Practice.where('group_schedule_id IN (?)', group.group_schedules.map(&:id))
    q = q.where('year > ? OR (year = ? and week >= ?)', first_session.year,
        first_session.year, first_session.cweek)
    q = q.where('year < ? OR (year = ? and week <= ?)', last_session.year,
        last_session.year, last_session.cweek)
    q
  end
end
