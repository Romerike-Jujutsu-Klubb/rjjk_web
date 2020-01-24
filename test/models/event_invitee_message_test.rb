# frozen_string_literal: true

require 'test_helper'

class EventInviteeMessageTest < ActiveSupport::TestCase
  test 'initialize INVITATION' do
    EventInviteeMessage.new(message_type: EventMessage::MessageType::INVITATION,
    event_invitee: event_invitees(:one))
  end

  test 'initialize INVITATION en' do
    users(:newbie).update! locale: 'en'
    EventInviteeMessage.new(message_type: EventMessage::MessageType::INVITATION,
    event_invitee: event_invitees(:one))
  end

  test 'initialize SIGNUP_CONFIRMATION' do
    EventInviteeMessage.new(message_type: EventInviteeMessage::MessageType::SIGNUP_CONFIRMATION,
    event_invitee: event_invitees(:one))
  end

  test 'initialize SIGNUP_REJECTION' do
    EventInviteeMessage.new(message_type: EventInviteeMessage::MessageType::SIGNUP_REJECTION,
    event_invitee: event_invitees(:one))
  end

  test 'existing event message' do
    EventInviteeMessage.new(message_type: EventMessage::MessageType::REMINDER,
        event_invitee: event_invitees(:one))
  end
end
