require File.dirname(__FILE__) + '/../test_helper'

class AttendancesControllerTest < ActionController::TestCase
  fixtures :attendances

  def setup
    super
    login(:admin)
  end

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
      post :create, attendance: {member_id: members(:uwe).id,
          practice_id: practices(:panda_2010_42).id,
          status: 'X'}
      assert_no_errors(:attendance)
    end

    assert_redirected_to attendance_path(assigns(:attendance))
  end

  def test_should_show_attendance
    get :show, :id => attendances(:lars_panda_2010_42).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => attendances(:lars_panda_2010_42).id
    assert_response :success
  end

  def test_should_update_attendance
    put :update, :id => attendances(:lars_panda_2010_42).id, :attendance => {}
    assert_redirected_to attendance_path(assigns(:attendance))
  end

  def test_should_destroy_attendance
    assert_difference('Attendance.count', -1) do
      delete :destroy, id: attendances(:lars_panda_2010_42).id
    end

    assert_redirected_to attendances_path
  end

  def test_should_get_plan
    get :plan
    assert_response :success
  end

  def test_should_get_review
    practice = practices(:voksne_2013_42_thursday)
    get :review,
        group_schedule_id: practice.group_schedule_id,
        year: practice.year, week: practice.week, status: :X
    assert_response :redirect
    assert_redirected_to 'http://test.host/mitt/oppmote'
  end

  def test_should_announce_toggle_off
    practice = practices(:voksne_2013_42_thursday)
    assert_equal 1, practice.attendances.count
    xhr :post, :announce, group_schedule_id: practice.group_schedule_id,
        year: practice.year, week: practice.week, status: 'toggle'
    assert_response :success
    assert_equal 0, practice.attendances.count
  end

  def test_should_announce_toggle_on
    login(:lars)
    practice = practices(:voksne_2013_42_thursday)
    assert_equal 1, practice.attendances.count
    xhr :post, :announce, group_schedule_id: practice.group_schedule_id,
        year: practice.year, week: practice.week, status: 'toggle'
    assert_response :success
    assert_equal 2, practice.attendances.count
  end

  def test_should_get_report
    get :report
    assert_response :success
  end

  def test_should_get_month_chart
    get :month_chart, year: 2013, month: 10, size: '800x300', format: 'png'
    assert_response :success
  end

  def test_should_get_history_chart
    get :history_graph, :id => '182', :format => 'png'
    assert_response :success
  end

  def test_should_get_form
    get :form, :date => '2013-10-01', :group_id => groups(:panda).id
    assert_response :success
  end

end
