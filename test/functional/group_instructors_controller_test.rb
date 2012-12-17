require 'test_helper'

class GroupInstructorsControllerTest < ActionController::TestCase
  setup do
    @groupinstructor = instructions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:group_instructors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create groupinstructor" do
    assert_difference('GroupInstructor.count') do
      post :create, groupinstructor: { from: @groupinstructor.from, group_id: @groupinstructor.group_id, member_id: @groupinstructor.member_id }
      assert_no_errors :groupinstructor
    end

    assert_redirected_to instruction_path(assigns(:groupinstructor))
  end

  test "should show groupinstructor" do
    get :show, id: @groupinstructor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @groupinstructor
    assert_response :success
  end

  test "should update groupinstructor" do
    put :update, id: @groupinstructor, groupinstructor: { from: @groupinstructor.from, group_id: @groupinstructor.group_id, member_id: @groupinstructor.member_id }
    assert_no_errors :groupinstructor
    assert_redirected_to instruction_path(assigns(:groupinstructor))
  end

  test "should destroy groupinstructor" do
    assert_difference('GroupInstructor.count', -1) do
      delete :destroy, id: @groupinstructor
    end

    assert_redirected_to instructions_path
  end
end
