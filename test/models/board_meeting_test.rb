# frozen_string_literal: true

require 'test_helper'

class BoardMeetingTest < ActiveSupport::TestCase
  test 'minutes=' do
    board_meetings(:one).minutes =
        Rack::Test::UploadedFile.new("#{self.class.fixture_path}files/board_meeting_minutes.txt")
  end
end
