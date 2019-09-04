# frozen_string_literal: true

require 'controller_test'

class TrialAttendancesControllerTest < ActionController::TestCase
  def setup
    login(:uwe)
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create trial_attendance' do
    assert_difference('TrialAttendance.count') do
      post :create, params: { trial_attendance: {
        practice_id: practices(:panda_2013_42).id,
        nkf_member_trial_id: nkf_member_trials(:two).id,
      } }
    end

    assert_redirected_to trial_attendance_path(TrialAttendance.last)
  end

  test 'should show trial_attendance' do
    get :show, params: { id: trial_attendances(:one).to_param }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: trial_attendances(:one).to_param }
    assert_response :success
  end

  test 'should update trial_attendance' do
    trial_attendance = trial_attendances(:one)
    put :update, params: { id: trial_attendance.to_param, trial_attendance: {
      practice_id: practices(:panda_2010_42).id,
    } }
    assert_redirected_to trial_attendance_path(trial_attendance)
  end

  test 'should destroy trial_attendance' do
    assert_difference('TrialAttendance.count', -1) do
      delete :destroy, params: { id: trial_attendances(:one).to_param }
    end

    assert_redirected_to trial_attendances_path
  end
end
