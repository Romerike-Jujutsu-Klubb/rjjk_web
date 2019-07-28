# frozen_string_literal: true

class InstructorMeeting < Event
  validates :end_at, :start_at, presence: true
  validates :name, length: { maximum: 254 }
end
