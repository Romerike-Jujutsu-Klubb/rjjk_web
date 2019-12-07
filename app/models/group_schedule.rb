# frozen_string_literal: true

class GroupSchedule < ApplicationRecord
  belongs_to :group

  has_one :last_practice, ->(gs) do
    now = Time.current
    date = now.to_date
    if gs.weekday > date.cwday ||
          (gs.weekday == date.cwday && (gs.start_at.nil? || gs.start_at > now.time_of_day))
      date -= 1.week
    end
    where(year: date.cwyear, week: date.cweek)
  end, class_name: :Practice, inverse_of: :group_schedule
  has_one :next_practice, ->(gs) do
    now = Time.current
    date = now.to_date
    if gs.weekday < date.cwday ||
          (gs.weekday == date.cwday && (gs.end_at.nil? || gs.end_at < now.time_of_day))
      date += 1.week
    end
    where(year: date.cwyear, week: date.cweek)
  end, class_name: :Practice, inverse_of: :group_schedule

  has_many :active_group_instructors, -> { active }, class_name: :GroupInstructor,
      inverse_of: :group_schedule
  has_many :group_instructors, dependent: :destroy
  has_many :practices, dependent: :destroy

  validates :end_at, :group, :start_at, :weekday, presence: true

  def next_practice
    super || create_next_practice
  end

  def to_s
    "#{group.full_name} #{ApplicationController.helpers.day_name weekday} #{start_at.to_s(false)}"
  end

  def instructor?(member)
    active_group_instructors.map(&:member).include? member
  end
end
