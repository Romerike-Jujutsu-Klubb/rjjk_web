# frozen_string_literal: true
class BoardMeeting < ActiveRecord::Base
  validates_presence_of :start_at

  def minutes=(file)
    return if file == ''
    self.minutes_filename = file.original_filename if minutes_filename.blank?
    self.minutes_content_type = file.content_type
    self.minutes_content_data = file.read
  end
end
