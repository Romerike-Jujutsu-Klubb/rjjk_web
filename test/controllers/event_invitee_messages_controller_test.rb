# frozen_string_literal: true

require 'test_helper'

class EventInviteeMessagesControllerTest < ActionController::TestCase
  setup do
    login :admin
    @event_invitee_message = event_invitee_messages(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:event_invitee_messages)
  end

  test 'should get new' do
    get :new, params: { event_invitee_message: { event_invitee_id: event_invitees(:one).id } }
    assert_response :success
  end

  test 'should create event_invitee_message' do
    assert_difference('EventInviteeMessage.count') do
      post :create, params: { event_invitee_message: {
          message_type: EventMessage::MessageType::INVITATION,
          body: @event_invitee_message.body,
          event_invitee_id: @event_invitee_message.event_invitee_id,
          sent_at: @event_invitee_message.sent_at,
          subject: @event_invitee_message.subject,
      } }
      assert_no_errors :event_invitee_message
    end
    assert_redirected_to event_invitee_message_path(assigns(:event_invitee_message))
  end

  test 'should show event_invitee_message' do
    get :show, params: { id: @event_invitee_message }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @event_invitee_message }
    assert_response :success
  end

  test 'should update event_invitee_message' do
    put :update, params: { id: @event_invitee_message, event_invitee_message: {
        message_type: EventMessage::MessageType::INVITATION,
        body: @event_invitee_message.body,
        event_invitee_id: @event_invitee_message.event_invitee_id,
        sent_at: @event_invitee_message.sent_at,
        subject: @event_invitee_message.subject,
    } }
    assert_no_errors :event_invitee_message
    assert_redirected_to event_invitee_message_path(assigns(:event_invitee_message))
  end

  test 'should destroy event_invitee_message' do
    assert_difference('EventInviteeMessage.count', -1) do
      delete :destroy, params: { id: @event_invitee_message }
      assert_no_errors :event_invitee_message
    end

    assert_redirected_to event_invitee_messages_path
  end
end
