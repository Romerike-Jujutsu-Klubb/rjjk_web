# frozen_string_literal: true

require 'test_helper'

class GoogleDriveServiceTest < ActiveSupport::TestCase
  def setup
    # Do nothing
  end

  def teardown
    # Do nothing
  end

  test 'initialize' do
    VCR.use_cassette('GoogleDriveInit') do
      GoogleDriveService.new
    end
  end

  test 'store and get image' do
    VCR.use_cassette('GoogleDriveStoreAndGetFile') do
      content = File.read("#{Rails.root}/test/fixtures/files/tiny.png")
      id = GoogleDriveService.new.store_file(:images, 42, content, 'image/png')
      file = GoogleDriveService.new.get_file(id)
      assert_equal content, file
    end
  end
end
