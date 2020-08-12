# frozen_string_literal: true

require 'test_helper'

class UserDrilldownControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get user_drilldown_url
    assert_response :success
  end
end
