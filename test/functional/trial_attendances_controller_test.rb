require File.dirname(__FILE__) + '/../test_helper'

class TrialAttendancesControllerTest < ActionController::TestCase
  fixtures :group_schedules, :nkf_member_trials

  def setup
    login(:admin)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:trial_attendances)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create trial_attendance" do
    assert_difference('TrialAttendance.count') do
      post :create, :trial_attendance => {
          :group_schedule_id => group_schedules(:one).id, :nkf_member_trial_id => nkf_member_trials(:one).id,
          :year => 2012, :week => 10
      }
      assert_no_errors :trial_attendance
    end

    assert_redirected_to trial_attendance_path(assigns(:trial_attendance))
  end

  test "should show trial_attendance" do
    get :show, :id => trial_attendances(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => trial_attendances(:one).to_param
    assert_response :success
  end

  test "should update trial_attendance" do
    put :update, :id => trial_attendances(:one).to_param, :trial_attendance => { }
    assert_redirected_to trial_attendance_path(assigns(:trial_attendance))
  end

  test "should destroy trial_attendance" do
    assert_difference('TrialAttendance.count', -1) do
      delete :destroy, :id => trial_attendances(:one).to_param
    end

    assert_redirected_to trial_attendances_path
  end
end
