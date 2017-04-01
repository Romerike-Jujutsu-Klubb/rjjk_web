# frozen_string_literal: true

require 'test_helper'

class GroupInstructorsControllerTest < ActionController::TestCase
  setup do
    @group_instructor = group_instructors(:one)
    login(:admin)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:semesters)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create group_instructor' do
    assert_difference('GroupInstructor.count') do
      post :create, params:{group_instructor: {
          group_schedule_id: @group_instructor.group_schedule_id,
          member_id: @group_instructor.member_id,
          group_semester_id: group_semesters(:current_panda).id,
          assistant: false,
      }}
      assert_no_errors :group_instructor
    end
    assert_redirected_to group_instructors_path
  end

  test 'should show group_instructor' do
    get :show, params:{id: @group_instructor}
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params:{id: @group_instructor}
    assert_response :success
  end

  test 'should update group_instructor' do
    put :update, params:{id: @group_instructor, group_instructor: {
        group_schedule_id: @group_instructor.group_schedule_id,
        member_id: @group_instructor.member_id,
        semester_id: @group_instructor.group_semester.semester_id,
    }}
    assert_no_errors :group_instructor
    assert_redirected_to group_instructors_path
  end

  test 'should destroy group_instructor' do
    assert_difference('GroupInstructor.count', -1) do
      delete :destroy, params:{id: @group_instructor}
      assert_no_errors :group_instructor
    end

    assert_redirected_to group_instructors_path
  end
end
