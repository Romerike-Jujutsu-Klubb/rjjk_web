# frozen_string_literal: true

require 'controller_test'

class GroupsControllerTest < ActionController::TestCase
  def setup
    login(:uwe)
  end

  def test_should_get_index
    get :index
    assert_response :success
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_group
    assert_difference('Group.count') do
      post :create, params: { group: {
        from_age: 8, curriculum_group_id: curriculum_groups(:voksne).id, name: 'New group', to_age: 10
      } }
    end

    assert_redirected_to group_path(Group.last)
  end

  def test_should_show_group
    get :show, params: { id: groups(:panda).id }
    assert_response :success
  end
  test 'should_show_group_without_current_semester' do
    get :show, params: { id: id(:voksne) }
    assert_response :success
  end

  def test_should_get_edit
    get :edit, params: { id: groups(:panda).id }
    assert_response :success
  end

  def test_should_update_group
    group = groups(:panda)
    put :update, params: { id: group.id, group: { from_age: 8 } }
    assert_redirected_to group_path(group)
  end

  def test_should_destroy_group
    assert_difference('Group.count', -1) do
      delete :destroy, params: { id: groups(:panda).id }
    end

    assert_redirected_to groups_path
  end
end
