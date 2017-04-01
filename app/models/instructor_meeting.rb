# frozen_string_literal: true

class InstructorMeeting < ActiveRecord::Base
  validates :end_at, :start_at, presence: true
  validates :title, length: { maximum: 254 }
end
