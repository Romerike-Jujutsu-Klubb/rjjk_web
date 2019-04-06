# frozen_string_literal: true

require 'test_helper'

class EventInviteeMessageTest < ActiveSupport::TestCase
  test 'initiaslize SIGNUP_CONFIRMATION' do
    EventInviteeMessage.new(message_type: EventInviteeMessage::MessageType::SIGNUP_CONFIRMATION,
    event_invitee: event_invitees(:one))
  end
  test 'initiaslize SIGNUP_REJECTION' do
    EventInviteeMessage.new(message_type: EventInviteeMessage::MessageType::SIGNUP_REJECTION,
    event_invitee: event_invitees(:one))
  end
end
