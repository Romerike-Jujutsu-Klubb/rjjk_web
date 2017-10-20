# frozen_string_literal: true

require 'integration_test'

class MapControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get map_url
    assert_response :success
  end
end
