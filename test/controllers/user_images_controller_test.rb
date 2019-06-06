# frozen_string_literal: true

require 'integration_test'

class UserImagesControllerTest < IntegrationTest
  test "must be a real test" do
    login :neuer
    post like_user_image_path(id(:one))
  end
end
