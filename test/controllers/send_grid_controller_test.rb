# frozen_string_literal: true

require 'test_helper'

class SendGridControllerTest < ActionDispatch::IntegrationTest
  test 'should receive email' do
    post send_grid_receive_url, params: {
      envelope: '{"to":["receiver@example.com"],"from":"test@example.com"}', email: 'raw email text'
    }
    assert_response :success
  end
end
