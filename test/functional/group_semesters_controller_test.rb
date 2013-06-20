require 'test_helper'

class GroupSemestersControllerTest < ActionController::TestCase
  setup do
    @group_semester = group_semesters(:one)
    login(:admin)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:group_semesters)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create group_semester' do
    assert_difference('GroupSemester.count') do
      post :create, group_semester: { first_session: @group_semester.first_session, group_id: @group_semester.group_id, last_session: @group_semester.last_session, semester_id: @group_semester.semester_id }
    end

    assert_redirected_to group_semester_path(assigns(:group_semester))
  end

  test 'should show group_semester' do
    get :show, id: @group_semester
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @group_semester
    assert_response :success
  end

  test 'should update group_semester' do
    put :update, id: @group_semester, group_semester: { first_session: @group_semester.first_session, group_id: @group_semester.group_id, last_session: @group_semester.last_session, semester_id: @group_semester.semester_id }
    assert_redirected_to group_semester_path(assigns(:group_semester))
  end

  test 'should destroy group_semester' do
    assert_difference('GroupSemester.count', -1) do
      delete :destroy, id: @group_semester
    end

    assert_redirected_to group_semesters_path
  end
end
