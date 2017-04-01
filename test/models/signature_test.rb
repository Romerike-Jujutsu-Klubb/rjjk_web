# frozen_string_literal: true

require 'test_helper'

class SignatureTest < ActiveSupport::TestCase
  test 'file=' do
    signatures(:lars).file = fixture_file_upload('files/board_meeting_minutes.txt', 'text/plain')
  end
end
