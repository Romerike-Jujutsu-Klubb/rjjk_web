class Attendance < ActiveRecord::Base
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
