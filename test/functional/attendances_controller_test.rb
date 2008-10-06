require 'test_helper'

class AttendancesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:attendances)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_attendance
    assert_difference('Attendance.count') do
      post :create, :attendance => { }
    end

    assert_redirected_to attendance_path(assigns(:attendance))
  end

  def test_should_show_attendance
    get :show, :id => attendances(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => attendances(:one).id
    assert_response :success
  end

  def test_should_update_attendance
    put :update, :id => attendances(:one).id, :attendance => { }
    assert_redirected_to attendance_path(assigns(:attendance))
  end

  def test_should_destroy_attendance
    assert_difference('Attendance.count', -1) do
      delete :destroy, :id => attendances(:one).id
    end

    assert_redirected_to attendances_path
  end
end
