class BoardMeeting < ActiveRecord::Base
  attr_accessible :annual_meeting_id, :minutes, :start_at

  belongs_to :annual_meeting

  def minutes=(file)
    return if file == ''
    self.minutes_filename = file.original_filename if minutes_filename.blank?
    self.minutes_content_type = file.content_type
    self.minutes_content_data = file.read
  end

end
