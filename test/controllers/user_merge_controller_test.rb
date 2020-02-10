# frozen_string_literal: true

require 'integration_test'

class UserMergeControllerTest < IntegrationTest
  setup { login }

  test 'show' do
    get user_merge_path(id(:uwe), other_user_id: id(:lars))
    assert_response :success
  end

  test 'update' do
    VCR.use_cassette('NKF Comparison Single Member Uwe', match_requests_on: %i[method host path query]) do
      patch user_merge_path(id(:uwe), other_user_id: id(:sebastian))
    end
    assert_redirected_to users(:uwe)
    assert_raise(ActiveRecord::RecordNotFound) { users(:sebastian) }
  end
end
