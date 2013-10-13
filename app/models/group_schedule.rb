# encoding: utf-8
class GroupSchedule < ActiveRecord::Base
  belongs_to :group
  has_many :attendances, :dependent => :destroy
  has_many :group_instructors, :dependent => :destroy
  has_many :trial_attendances, :dependent => :destroy

  validates_presence_of :end_at, :group, :start_at, :weekday

  def weekday_name
    I18n.t(:date)[:day_names][weekday]
  end

  def next_practice
    now = Time.now
    today = now.to_date
    Date.commercial today.cwyear, (
    if weekday > today.cwday || (weekday == today.cwday && end_at > now.time_of_day) then
      today.cweek
    else
      today.cweek + 1
    end), weekday
  end
end
