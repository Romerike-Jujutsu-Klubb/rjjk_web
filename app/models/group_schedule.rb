# encoding: utf-8
class GroupSchedule < ActiveRecord::Base
  belongs_to :group
  has_many :attendances, :dependent => :destroy
  has_many :group_instructors
  has_many :trial_attendances, :dependent => :destroy

  validates_presence_of :end_at, :group, :start_at, :weekday

  def weekday_name
    {
        1 => 'Mandag', 2 => 'Tirsdag', 3 => 'Onsdag', 4 => 'Torsdag', 5 => 'Fredag', 6 => 'Lørdag',
        7 => 'Søndag'
    }[weekday]
  end

  def next_practice
    today = Date.today
    Date.commercial today.cwyear, weekday >= today.cwday ? today.cweek : today.cweek + 1, weekday
  end
end
