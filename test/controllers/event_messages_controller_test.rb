# frozen_string_literal: true

require 'controller_test'

class EventMessagesControllerTest < ActionController::TestCase
  setup do
    login :admin
    @event_message = event_messages(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create event_message' do
    assert_difference('EventMessage.count') do
      post :create, params: { event_message: {
        body: @event_message.body,
        event_id: @event_message.event_id,
        message_type: EventMessage::MessageType::INVITATION,
        ready_at: @event_message.ready_at,
        subject: @event_message.subject,
      } }
    end

    assert_redirected_to edit_event_message_path(EventMessage.last, anchor: :messages_tab)
  end

  test 'should show event_message' do
    get :show, params: { id: @event_message }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @event_message }
    assert_response :success
  end

  test 'should update event_message' do
    put :update, params: { id: @event_message, event_message: {
      body: @event_message.body,
      event_id: @event_message.event_id,
      message_type: @event_message.message_type,
      ready_at: @event_message.ready_at,
      subject: @event_message.subject,
    } }
    assert_redirected_to event_message_path(@event_message)
  end

  test 'should destroy event_message' do
    assert_difference('EventMessage.count', -1) do
      delete :destroy, params: { id: @event_message }
    end

    assert_redirected_to edit_event_path(@event_message.event, anchor: :messages_tab)
  end
end
