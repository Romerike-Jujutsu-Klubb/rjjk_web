# frozen_string_literal: true
class Practice < ActiveRecord::Base
  belongs_to :group_schedule

  has_many :attendances, dependent: :destroy
  has_many :trial_attendances, dependent: :destroy

  validates_uniqueness_of :group_schedule_id, scope: [:year, :week]

  def date
    Date.commercial(year, week, group_schedule.weekday)
  end

  def start_at
    date.at(group_schedule.start_at)
  end

  def passed?
    Time.now > date.at(group_schedule.end_at)
  end

  def to_s
    "#{group_schedule.group.name} #{date} #{group_schedule.start_at}"
  end
end
