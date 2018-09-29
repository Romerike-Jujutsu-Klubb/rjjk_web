# frozen_string_literal: true

require 'test_helper'

class GoogleDriveServiceTest < ActiveSupport::TestCase
  test 'initialize' do
    VCR.use_cassette('GoogleDriveInit') { GoogleDriveService.new }
  end

  test 'store and get image' do
    VCR.use_cassette('GoogleDriveStoreAndGetFile') do
      expected_content = File.read("#{Rails.root}/test/fixtures/files/tiny.png")
      file = GoogleDriveService.new.store_file(:images, 42, expected_content, 'image/png')
      content = GoogleDriveService.new.get_file_content(file.id)
      assert_equal expected_content, content
    end
  end
end
