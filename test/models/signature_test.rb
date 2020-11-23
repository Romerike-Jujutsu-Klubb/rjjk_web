# frozen_string_literal: true

require 'test_helper'

class SignatureTest < ActiveSupport::TestCase
  test 'file=' do
    signatures(:lars).file =
        Rack::Test::UploadedFile.new("#{self.class.fixture_path}files/board_meeting_minutes.txt")
  end
end
