class Attendance < ActiveRecord::Base
  belongs_to :member
  belongs_to :group_schedule
  
  validates_uniqueness_of :member_id, :scope => [:group_schedule_id, :year, :week]
  
  def date
    Date.commercial(year, week, group_schedule.weekday)
  end
  
end
