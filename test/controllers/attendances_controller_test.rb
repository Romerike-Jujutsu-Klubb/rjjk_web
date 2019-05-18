# frozen_string_literal: true

require 'controller_test'

class AttendancesControllerTest < ActionController::TestCase
  setup { login(:admin) }

  def test_should_get_index
    get :index
    assert_response :success
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_attendance
    assert_difference('Attendance.count') do
      post :create, params: { attendance: {
        member_id: members(:uwe).id, practice_id: practices(:panda_2010_42).id, status: 'X'
      } }
    end

    assert_redirected_to attendance_path(Attendance.last)
  end

  def test_create_with_group_schedule_id_and_year_and_week
    assert_difference('Attendance.count') do
      post :create, params: { attendance: { member_id: members(:uwe).id,
                                            group_schedule_id: group_schedules(:panda).id, year: 2010, week: 42,
                                            status: 'X' } }
    end
    assert_redirected_to attendance_path(Attendance.last)
  end

  def test_should_show_attendance
    get :show, params: { id: attendances(:lars_panda_2010_42).id }
    assert_response :success
  end

  def test_should_get_edit
    get :edit, params: { id: attendances(:lars_panda_2010_42).id }
    assert_response :success
  end

  def test_should_update_attendance
    attendance = attendances(:lars_panda_2010_42)
    put :update, params: { id: attendance.id, attendance: { status: 'X' } }
    assert_redirected_to attendance_path(attendance)
  end

  def test_should_destroy_attendance
    assert_difference('Attendance.count', -1) do
      delete :destroy, params: { id: attendances(:lars_panda_2010_42).id }
    end

    assert_redirected_to attendances_path
  end

  def test_should_get_plan
    get :plan
    assert_response :success
  end

  def test_should_get_review
    practice = practices(:voksne_2013_42_thursday)
    Attendance::Status.constants(false).map(&Attendance::Status.method(:const_get)).each do |status|
      login(:admin)
      get :review, params: {
          group_schedule_id: practice.group_schedule_id,
          year: practice.year, week: practice.week, status: status
      }
      assert_response :redirect
      assert_redirected_to 'http://test.host/mitt/oppmote/911313225'
    end
  end

  def test_should_get_review_en
    I18n.with_locale(:en) { test_should_get_review }
  end

  def test_should_announce_toggle_off
    practice = practices(:voksne_2013_42_thursday)
    assert_equal 1, practice.attendances.count
    post :announce, params: { group_schedule_id: practice.group_schedule_id,
                              year: practice.year, week: practice.week, status: 'toggle' }, xhr: true
    assert_response :success
    assert_equal 0, practice.attendances.count
  end

  def test_should_announce_toggle_on
    login(:lars)
    practice = practices(:voksne_2013_42_thursday)
    assert_equal 1, practice.attendances.count
    post :announce, params: { group_schedule_id: practice.group_schedule_id,
                              year: practice.year, week: practice.week, status: 'toggle' }, xhr: true
    assert_response :success
    assert_equal 2, practice.attendances.count
  end

  def test_should_get_report
    get :report
    assert_response :success
  end

  def test_should_get_month_chart
    get :month_chart, params: { year: 2013, month: 10 }
    assert_response :success
  end

  def test_should_get_month_per_year_chart
    get :month_per_year_chart, params: { year: 2013, month: 10 }
    assert_response :success
  end

  def test_should_get_history_chart
    get :history_graph
    assert_response :success
  end

  def test_should_get_history_chart_data
    get :history_graph_data
    assert_response :success
    assert_equal <<~JSON.chomp, response.body
      [{"name":"Voksne","data":[["2010-08-23",null],["2010-09-20",null],["2010-10-18",null],["2010-11-15",null],["2010-12-13",null],["2011-01-10",null],["2011-02-07",null],["2011-03-07",null],["2011-04-04",null],["2011-05-02",null],["2011-05-30",null],["2011-06-27",null],["2011-07-25",null],["2011-08-22",null],["2011-09-19",null],["2011-10-17",null],["2011-11-14",null],["2011-12-12",null],["2012-01-09",null],["2012-02-06",null],["2012-03-05",null],["2012-04-02",null],["2012-04-30",null],["2012-05-28",null],["2012-06-25",null],["2012-07-23",null],["2012-08-20",null],["2012-09-17",null],["2012-10-15",null],["2012-11-12",null],["2012-12-10",null],["2013-01-07",null],["2013-02-04",null],["2013-03-04",null],["2013-04-01",null],["2013-04-29",null],["2013-05-27",null],["2013-06-24",null],["2013-07-22",null],["2013-08-19",null],["2013-09-16",1],["2013-10-14",null]],"color":null},{"name":"Panda","data":[["2010-08-23",null],["2010-09-20",2],["2010-10-18",null],["2010-11-15",null],["2010-12-13",null],["2011-01-10",null],["2011-02-07",null],["2011-03-07",null],["2011-04-04",null],["2011-05-02",null],["2011-05-30",null],["2011-06-27",null],["2011-07-25",null],["2011-08-22",null],["2011-09-19",null],["2011-10-17",null],["2011-11-14",null],["2011-12-12",null],["2012-01-09",null],["2012-02-06",null],["2012-03-05",null],["2012-04-02",null],["2012-04-30",null],["2012-05-28",null],["2012-06-25",null],["2012-07-23",null],["2012-08-20",null],["2012-09-17",null],["2012-10-15",null],["2012-11-12",null],["2012-12-10",null],["2013-01-07",null],["2013-02-04",null],["2013-03-04",null],["2013-04-01",null],["2013-04-29",null],["2013-05-27",null],["2013-06-24",null],["2013-07-22",null],["2013-08-19",null],["2013-09-16",1],["2013-10-14",null]],"color":null}]
    JSON
  end
end
