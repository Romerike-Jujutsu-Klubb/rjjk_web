# frozen_string_literal: true

class Practice < ApplicationRecord
  belongs_to :group_schedule

  has_many :attendances, dependent: :destroy
  has_many :trial_attendances, dependent: :destroy

  scope :after, ->(limit) {
                  from_date = limit.to_date
                  includes(:group_schedule).references(:group_schedules)
                      .where('year > :year OR (year = :year AND week > :week) OR ' \
                      '(year = :year AND week = :week AND group_schedules.weekday > :wday)',
                          year: from_date.cwyear, week: from_date.cweek, wday: from_date.cwday)
                }

  validates :group_schedule_id, uniqueness: { scope: %i[year week] }

  def group_semester
    GroupSemester.where(group_id: group_schedule.group_id)
        .find_by('first_session <= :date AND last_session >= :date', date: date)
  end

  def date
    Date.commercial(year, week, group_schedule.weekday)
  end

  def start_at
    date.at(group_schedule.start_at)
  end

  def end_at
    date.at(group_schedule.end_at)
  end

  def imminent?
    Time.current > (start_at - 30.minutes)
  end

  def passed?
    Time.current > end_at
  end

  def to_s
    "#{group_schedule.group.full_name} #{date} #{group_schedule.start_at.to_s(false)}"
  end

  def attendance_for(member_id)
    attendances.find { |a| a.member_id == member_id }
  end
end
