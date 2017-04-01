# frozen_string_literal: true

require 'test_helper'

class BoardMeetingTest < ActiveSupport::TestCase
  test 'minutes=' do
    board_meetings(:one).minutes = fixture_file_upload('files/board_meeting_minutes.txt', 'text/plain')
  end
end
