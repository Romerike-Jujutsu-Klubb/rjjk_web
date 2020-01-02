# frozen_string_literal: true

require 'integration_test'

class StatusControllerTest < IntegrationTest
  test 'should get index' do
    get status_url
    assert_response :success
  end

  test 'should get health' do
    get status_health_url
    assert_response :success
  end
end
