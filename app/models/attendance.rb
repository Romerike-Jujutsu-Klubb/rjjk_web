class Attendance < ActiveRecord::Base
  named_scope :by_group_id, lambda { |group_id| { :conditions => ['group_schedules.group_id = ?', group_id], :include => :group_schedule }}
  named_scope :last_months, lambda { |count| { :conditions => ['(year = ? AND week >= ?) OR year > ?', count.months.ago.year, count.months.ago.to_date.cweek, count.months.ago.year]}}

  belongs_to :member
  belongs_to :group_schedule
  
  validates_uniqueness_of :member_id, :scope => [:group_schedule_id, :year, :week]
  
  def date
    Date.commercial(year, week, group_schedule.weekday)
  end
  
  def self.find_member_count_for_month(group, year, month)
    find(:all, :conditions => ['group_schedule_id IN ? AND year = ?', group.group_schedules.map{|gs| gs.id}, year, month])
  end
  
end
