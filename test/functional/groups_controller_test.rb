require File.dirname(__FILE__) + '/../test_helper'

class GroupsControllerTest < ActionController::TestCase
  def setup
    login(:admin)
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_group
    assert_difference('Group.count') do
      post :create, :group => {
          :from_age => 8, :martial_art_id => martial_arts(:keiwaryu).id, :name => 'New group', :to_age => 10
      }
      assert_no_errors :group
    end

    assert_redirected_to group_path(assigns(:group))
  end

  def test_should_show_group
    get :show, :id => groups(:panda).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => groups(:panda).id
    assert_response :success
  end

  def test_should_update_group
    put :update, :id => groups(:panda).id, :group => {}
    assert_redirected_to group_path(assigns(:group))
  end

  def test_should_destroy_group
    assert_difference('Group.count', -1) do
      delete :destroy, :id => groups(:panda).id
    end

    assert_redirected_to groups_path
  end
end
