require 'test_helper'

class RolesControllerTest < ActionController::TestCase
  setup do
    @role = roles(:chairman)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:roles)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create role' do
    assert_difference('Role.count') do
      post :create, role: {name: @role.name, years_on_the_board: @role.years_on_the_board}
    end

    assert_redirected_to role_path(assigns(:role))
  end

  test 'should show role' do
    get :show, id: @role
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @role
    assert_response :success
  end

  test 'should update role' do
    put :update, id: @role, role: {name: @role.name, years_on_the_board: @role.years_on_the_board}
    assert_redirected_to role_path(assigns(:role))
  end

  test 'should not destroy role if election exists' do
    assert_no_difference('Role.count') do
      assert_raise ActiveRecord::InvalidForeignKey do
        delete :destroy, id: @role
      end
    end
  end

  test 'should destroy role when no elecitons exist' do
    @role.elections.destroy_all
    assert_difference('Role.count', -1) do
      delete :destroy, id: @role
    end

    assert_redirected_to roles_path
  end
end
