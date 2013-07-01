require File.dirname(__FILE__) + '/../test_helper'

class GroupSchedulesControllerTest < ActionController::TestCase
  def setup
    login(:admin)
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:group_schedules)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_group_schedule
    assert_difference('GroupSchedule.count') do
      post :create, :group_schedule => {:end_at => '18:45', :group_id => groups(:panda).id, :start_at => '17:45', :weekday => 1}
      assert_no_errors :group_schedule
    end

    assert_redirected_to group_schedule_path(assigns(:group_schedule))
  end

  def test_should_show_group_schedule
    get :show, :id => group_schedules(:panda).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => group_schedules(:panda).id
    assert_response :success
  end

  def test_should_update_group_schedule
    put :update, :id => group_schedules(:panda).id, :group_schedule => { }
    assert_redirected_to group_schedule_path(assigns(:group_schedule))
  end

  def test_should_destroy_group_schedule
    assert_difference('GroupSchedule.count', -1) do
      delete :destroy, :id => group_schedules(:panda).id
    end

    assert_redirected_to group_schedules_path
  end
end
