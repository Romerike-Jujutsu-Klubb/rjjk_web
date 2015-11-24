class InstructorMeeting < ActiveRecord::Base
  validates_presence_of :end_at, :start_at
  validates_length_of :title, maximum: 254
end
