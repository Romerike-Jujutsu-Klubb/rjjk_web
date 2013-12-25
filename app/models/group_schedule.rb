# encoding: utf-8
class GroupSchedule < ActiveRecord::Base
  belongs_to :group
  has_many :group_instructors, :dependent => :destroy
  has_many :practices, :dependent => :destroy

  validates_presence_of :end_at, :group, :start_at, :weekday

  def weekday_name
    I18n.t(:date)[:day_names][weekday]
  end

  def next_practice(now = Time.now)
    date = now.to_date
    date += 1.week if weekday < date.cwday ||
        (weekday == date.cwday && end_at <= now.time_of_day)
    Practice.where(:group_schedule_id => id, :year => date.cwyear,
        :week => date.cweek).first_or_create!
  end

  def to_s
    "#{group.name} #{weekday_name}"
  end

end
