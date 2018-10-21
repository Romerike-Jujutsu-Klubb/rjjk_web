# frozen_string_literal: true

require 'test_helper'

class AttendanceWebpushesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @attendance_webpush = attendance_webpushes(:one)
  end

  test 'should get index' do
    get attendance_webpushes_url
    assert_response :success
  end

  test 'should get new' do
    get new_attendance_webpush_url
    assert_response :success
  end

  test 'should create attendance_webpush' do
    assert_difference('AttendanceWebpush.count') do
      post attendance_webpushes_url, params: { attendance_webpush: {
        auth: @attendance_webpush.auth, endpoint: @attendance_webpush.endpoint,
        member_id: id(:sebastian), p256dh: @attendance_webpush.p256dh
      } }
    end

    assert_redirected_to attendance_webpush_url(AttendanceWebpush.last)
  end

  test 'should show attendance_webpush' do
    get attendance_webpush_url(@attendance_webpush)
    assert_response :success
  end

  test 'should get edit' do
    get edit_attendance_webpush_url(@attendance_webpush)
    assert_response :success
  end

  test 'should update attendance_webpush' do
    patch attendance_webpush_url(@attendance_webpush), params: { attendance_webpush: {
      auth: @attendance_webpush.auth, endpoint: @attendance_webpush.endpoint,
      member_id: id(:sebastian), p256dh: @attendance_webpush.p256dh
    } }
    assert_redirected_to attendance_webpush_url(@attendance_webpush)
  end

  test 'should destroy attendance_webpush' do
    assert_difference('AttendanceWebpush.count', -1) do
      delete attendance_webpush_url(@attendance_webpush)
    end

    assert_redirected_to attendance_webpushes_url
  end
end
