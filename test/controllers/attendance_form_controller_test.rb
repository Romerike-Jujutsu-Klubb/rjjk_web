# frozen_string_literal: true

require 'test_helper'

class AttendanceFormControllerTest < ActionDispatch::IntegrationTest
  setup { login(:uwe) }

  test 'should get index' do
    get attendance_forms_url
    assert_response :success
  end

  test 'should get show' do
    get attendance_form_url year: 2013, month: 10, group_id: id(:panda)
    assert_response :success
  end
end
