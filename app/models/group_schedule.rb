# encoding: utf-8
class GroupSchedule < ActiveRecord::Base
  belongs_to :group
  has_many :group_instructors, :dependent => :destroy
  has_many :practices, :dependent => :destroy

  validates_presence_of :end_at, :group, :start_at, :weekday

  def weekday_name
    I18n.t(:date)[:day_names][weekday]
  end

  def next_practice
    now = Time.now
    today = now.to_date
    week = weekday > today.cwday || (weekday == today.cwday && end_at > now.time_of_day) ?
        today.cweek : today.cweek + 1
    Practice.where(:group_schedule_id => id, :year => today.cwyear,
                   :week => week).first_or_create!
  end


end
