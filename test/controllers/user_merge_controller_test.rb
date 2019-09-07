# frozen_string_literal: true

require 'integration_test'

class UserMergeControllerTest < IntegrationTest
  setup { login }

  test 'show' do
    get user_merge_path(id(:uwe))
    assert_response :success
  end

  test 'update' do
    patch user_merge_path(id(:uwe))
    assert_redirected_to users(:uwe)
  end
end
