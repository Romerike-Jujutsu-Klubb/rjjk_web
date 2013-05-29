class GroupInstructor < ActiveRecord::Base
  attr_accessible :from, :group_schedule_id, :member_id, :to

  belongs_to :group_schedule
  belongs_to :member

  validates_presence_of :from, :group_schedule, :group_schedule_id, :member, :member_id

  validates_uniqueness_of :from, :scope => :group_schedule_id

  def active?(date = Date.today)
    from <= date && (to.nil? || to >= date)
  end

end
