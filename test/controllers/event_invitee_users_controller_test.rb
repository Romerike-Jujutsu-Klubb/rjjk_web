# frozen_string_literal: true

require 'test_helper'

class EventInviteeUsersControllerTest < ActionDispatch::IntegrationTest
  test('should get index') { get event_invitee_users_path }
  test('should get show') { get event_invitee_user_path id(:one) }
  test('should get accept') { get accept_event_invitee_user_path id(:one) }
  test('should get decline') { get decline_event_invitee_user_path id(:one) }
  test('should get will_work') { get will_work_event_invitee_user_path id(:one) }
  test('should get will_not_work') { get will_not_work_event_invitee_user_path id(:one) }
end
