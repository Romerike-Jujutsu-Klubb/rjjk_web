# frozen_string_literal: true

require 'controller_test'

class BoardMeetingsControllerTest < ActionController::TestCase
  setup do
    @board_meeting = board_meetings(:one)
    login(:admin)
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create board_meeting' do
    assert_difference('BoardMeeting.count') do
      post :create, params: { board_meeting: { start_at: @board_meeting.start_at } }
    end
    assert_redirected_to board_meetings_path
  end

  test 'should show board_meeting' do
    get :show, params: { id: @board_meeting }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @board_meeting }
    assert_response :success
  end

  test 'should update board_meeting' do
    put :update, params: { id: @board_meeting, board_meeting: { start_at: @board_meeting.start_at } }
    assert_redirected_to board_meetings_path
  end

  test 'should destroy board_meeting' do
    assert_difference('BoardMeeting.count', -1) do
      delete :destroy, params: { id: @board_meeting }
    end

    assert_redirected_to board_meetings_path
  end
end
