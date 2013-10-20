class Practice < ActiveRecord::Base
  attr_accessible :group_schedule_id, :status, :week, :year

  belongs_to :group_schedule

  has_many :attendances, :dependent => :destroy

  validates_uniqueness_of :group_schedule_id, :scope => [:year, :week]

  def date
    Date.commercial(year, week, group_schedule.weekday)
  end

end
