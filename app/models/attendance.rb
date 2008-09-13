class Attendance < ActiveRecord::Base
  belongs_to :member
  belongs_to :group_schedule
  
  # Uncomment when derby properly quotes the "year" column.
  validates_uniqueness_of :member_id, :scope => [:group_schedule_id, :year, :week]
end
