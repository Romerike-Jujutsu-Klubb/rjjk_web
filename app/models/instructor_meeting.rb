class InstructorMeeting < ActiveRecord::Base
  validates_presence_of :agenda, :end_at, :start_at, :title
  validates_length_of :title, maximum: 254
end
