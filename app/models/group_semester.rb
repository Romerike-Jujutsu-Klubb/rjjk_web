# frozen_string_literal: true

class GroupSemester < ApplicationRecord
  belongs_to :chief_instructor, class_name: 'Member', optional: true
  belongs_to :group
  belongs_to :semester

  has_many :group_instructors, dependent: :destroy

  has_many :group_schedules, through: :group
  has_many :practices, ->(gs) {
                         where('year > :year OR (year = :year and week >= :week)',
                             year: gs.first_session.cwyear, week: gs.first_session.cweek)
                             .where('year < :year OR (year = :year and week <= :week)',
                                 year: gs.last_session.cwyear, week: gs.last_session.cweek)
                       },
      through: :group_schedules

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
end
