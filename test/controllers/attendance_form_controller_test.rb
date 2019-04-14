# frozen_string_literal: true

require 'test_helper'

class AttendanceFormControllerTest < ActionDispatch::IntegrationTest
  setup { login(:admin) }

  test 'should get index' do
    get attendance_forms_url
    assert_response :success
  end

  test 'should get show' do
    get attendance_form_url year: 2013, month: 10, group_id: id(:panda)
    assert_response :success
  end

  # test 'should get update' do
  #   patch attendance_form_url
  #   assert_response :success
  # end

  def test_should_get_form
    get attendance_form_url(year: 2013, month: 10, group_id: id(:panda))
    assert_response :success
  end

  # def test_should_get_form_without_group_id
  #   GroupMembership.delete_all
  #   get attendance_form_url year: 2013, month: 10
  #   assert_response :success
  # end

  test 'should get form for others' do
    GroupMembership.delete_all
    get attendance_form_url year: 2013, month: 10, group_id: :others
    assert_response :success
  end
end
