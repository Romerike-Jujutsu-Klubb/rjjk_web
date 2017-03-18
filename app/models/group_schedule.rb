# frozen_string_literal: true
class GroupSchedule < ActiveRecord::Base
  belongs_to :group
  has_many :group_instructors, dependent: :destroy
  has_many :practices, dependent: :destroy

  validates :end_at, :group, :start_at, :weekday, presence: true

  def weekday_name
    I18n.t(:date)[:day_names][weekday]
  end

  def next_practice(now = Time.current)
    date = now.to_date
    date += 1.week if weekday < date.cwday ||
          (weekday == date.cwday && (end_at.nil? || end_at <= now.time_of_day))
    Practice.where(group_schedule_id: id, year: date.cwyear, week: date.cweek).first_or_create!
  end

  def to_s
    "#{group.full_name} #{weekday_name} #{start_at.to_s(false)}"
  end
end
