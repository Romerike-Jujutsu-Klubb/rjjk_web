# frozen_string_literal: true

require 'controller_test'

class InstructorMeetingsControllerTest < ActionController::TestCase
  setup do
    @instructor_meeting = instructor_meetings(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create instructor_meeting' do
    assert_difference('InstructorMeeting.count') do
      post :create, params: { instructor_meeting: {
        agenda: @instructor_meeting.agenda,
        end_at: @instructor_meeting.end_at,
        start_at: @instructor_meeting.start_at,
        title: @instructor_meeting.title,
      } }
    end

    assert_redirected_to instructor_meetings_path
  end

  test 'should show instructor_meeting' do
    get :show, params: { id: @instructor_meeting }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @instructor_meeting }
    assert_response :success
  end

  test 'should update instructor_meeting' do
    patch :update, params: { id: @instructor_meeting, instructor_meeting: {
      agenda: @instructor_meeting.agenda,
      end_at: @instructor_meeting.end_at,
      start_at: @instructor_meeting.start_at,
      title: @instructor_meeting.title,
    } }
    assert_redirected_to instructor_meetings_path
  end

  test 'should destroy instructor_meeting' do
    assert_difference('InstructorMeeting.count', -1) do
      delete :destroy, params: { id: @instructor_meeting }
    end

    assert_redirected_to instructor_meetings_path
  end
end
