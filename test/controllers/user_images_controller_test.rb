# frozen_string_literal: true

require 'integration_test'

class UserImagesControllerTest < IntegrationTest
  test 'test like' do
    login :neuer
    post like_user_image_path(id(:one))
  end
end
