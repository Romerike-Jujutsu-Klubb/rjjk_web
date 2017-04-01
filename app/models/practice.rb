# frozen_string_literal: true

class Practice < ActiveRecord::Base
  belongs_to :group_schedule

  has_many :attendances, dependent: :destroy
  has_many :trial_attendances, dependent: :destroy

  validates :group_schedule_id, uniqueness: { scope: %i(year week) }

  def date
    Date.commercial(year, week, group_schedule.weekday)
  end

  def start_at
    date.at(group_schedule.start_at)
  end

  def passed?
    Time.current > date.at(group_schedule.end_at)
  end

  def to_s
    "#{group_schedule.group.full_name} #{date} #{group_schedule.start_at.to_s(false)}"
  end
end
