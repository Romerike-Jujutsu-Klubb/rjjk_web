require 'test_helper'

class BoardMeetingsControllerTest < ActionController::TestCase
  setup do
    @board_meeting = board_meetings(:one)
    login(:admin)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:board_meetings)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create board_meeting' do
    assert_difference('BoardMeeting.count') do
      post :create, board_meeting: { annual_meeting_id: @board_meeting.annual_meeting_id, start_at: @board_meeting.start_at }
      assert_no_errors :board_meeting
    end

    assert_redirected_to board_meeting_path(assigns(:board_meeting))
  end

  test 'should show board_meeting' do
    get :show, id: @board_meeting
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @board_meeting
    assert_response :success
  end

  test 'should update board_meeting' do
    put :update, id: @board_meeting, board_meeting: { annual_meeting_id: @board_meeting.annual_meeting_id, start_at: @board_meeting.start_at }
    assert_redirected_to board_meeting_path(assigns(:board_meeting))
  end

  test 'should destroy board_meeting' do
    assert_difference('BoardMeeting.count', -1) do
      delete :destroy, id: @board_meeting
    end

    assert_redirected_to board_meetings_path
  end
end
