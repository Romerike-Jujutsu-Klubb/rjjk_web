require 'test_helper'

class EventMessagesControllerTest < ActionController::TestCase
  setup do
    @event_message = event_messages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:event_messages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create event_message" do
    assert_difference('EventMessage.count') do
      post :create, event_message: { body: @event_message.body, event_id: @event_message.event_id, message_type: @event_message.message_type, ready_at: @event_message.ready_at, subject: @event_message.subject }
    end

    assert_redirected_to event_message_path(assigns(:event_message))
  end

  test "should show event_message" do
    get :show, id: @event_message
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @event_message
    assert_response :success
  end

  test "should update event_message" do
    put :update, id: @event_message, event_message: { body: @event_message.body, event_id: @event_message.event_id, message_type: @event_message.message_type, ready_at: @event_message.ready_at, subject: @event_message.subject }
    assert_redirected_to event_message_path(assigns(:event_message))
  end

  test "should destroy event_message" do
    assert_difference('EventMessage.count', -1) do
      delete :destroy, id: @event_message
    end

    assert_redirected_to event_messages_path
  end
end
