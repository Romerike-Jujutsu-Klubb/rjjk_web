class Attendance < ActiveRecord::Base
  ABSENT = 'F'
  ASSISTANT = 'H'
  ATTENDED = 'X'
  HOLIDAY = 'B'
  INSTRUCTOR = 'I'
  PRESENT = 'T'
  SICK = 'S'
  WILL_ATTEND = 'P'

  STATES = [
      [Attendance::HOLIDAY, 'Bortreist', 'icon-hand-right', 'btn-warning'],
      [Attendance::SICK, 'Syk', 'icon-plus', 'btn-danger'],
      [Attendance::ABSENT, 'Annet', 'icon-thumbs-down', 'btn-info'],
  ]

  scope :by_group_id, lambda { |group_id| { :conditions => ['group_schedules.group_id = ?', group_id], :include => :group_schedule }}
  scope :last_months, lambda { |count| limit = count.months.ago ; { :conditions => ['(year = ? AND week >= ?) OR year > ?', limit.year, limit.to_date.cweek, limit.year]}}
  scope :on_date, lambda { |date| { :conditions => ['year = ? AND week = ?', date.year, date.cweek]}}

  belongs_to :member
  belongs_to :group_schedule

  validates_presence_of :member_id, :status
  validates_uniqueness_of :member_id, :scope => [:group_schedule_id, :year, :week]
  
  def date
    Date.commercial(year, week, group_schedule.weekday)
  end
  
  #def self.find_member_count_for_month(group, year, month)
  #  find(:all, :conditions => ['group_schedule_id IN ? AND year = ?', group.group_schedules.map{|gs| gs.id}, year, month])
  #end
  
end
