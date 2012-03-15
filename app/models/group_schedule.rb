class GroupSchedule < ActiveRecord::Base
  belongs_to :group

  validates_presence_of :end_at, :group, :start_at, :weekday
end
