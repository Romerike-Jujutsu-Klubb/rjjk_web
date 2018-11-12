# frozen_string_literal: true

require 'integration_test'

class ImageDropzoneControllerTest < IntegrationTest
  test 'should get upload' do
    post image_dropzone_upload_url, params: { image: { file: fixture_file_upload('files/tiny.png') } }
    assert_response :success
  end
end
