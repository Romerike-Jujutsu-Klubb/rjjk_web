# frozen_string_literal: true

require 'test_helper'

class EventInviteeUsersControllerTest < ActionDispatch::IntegrationTest
  setup { login :newbie }
  test('should get index') do
    get event_registration_index_path
    assert_response :success
  end
  test('should get show') do
    get event_registration_path id(:one)
    assert_response :success
  end
  test('should get accept') do
    get accept_event_registration_path id(:one)
    assert_redirected_to event_registration_path(id(:one))
  end
  test('should get decline') do
    get decline_event_registration_path id(:one)
    assert_redirected_to event_registration_path(id(:one))
  end
  test('should get will_work') do
    get will_work_event_registration_path id(:one)
    assert_redirected_to event_registration_path(id(:one))
  end
  test('should get will_not_work') do
    get will_not_work_event_registration_path id(:one)
    assert_redirected_to event_registration_path(id(:one))
  end
end
