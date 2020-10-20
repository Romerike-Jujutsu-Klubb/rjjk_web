# frozen_string_literal: true

require 'test_helper'

class AttendanceFormControllerTest < ActionDispatch::IntegrationTest
  setup { login(:uwe) }

  test 'should get index' do
    get attendance_forms_url
    assert_response :success
  end
end
