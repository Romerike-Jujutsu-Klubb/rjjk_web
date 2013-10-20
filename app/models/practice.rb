class Practice < ActiveRecord::Base
  attr_accessible :group_schedule_id, :status, :week, :year

  belongs_to :group_schedule

  has_many :attendances, :dependent => :destroy

  def date
    Date.commercial(year, week, group_schedule.weekday)
  end

end
