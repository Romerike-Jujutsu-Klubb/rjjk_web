# frozen_string_literal: true

require 'controller_test'

class GroupSemestersControllerTest < ActionController::TestCase
  setup do
    @group_semester = group_semesters(:previous_panda)
    login(:uwe)
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
    assert_select 'textarea[name="group_semester[summary]"]'
  end

  test 'should create group_semester' do
    assert_difference('GroupSemester.count') do
      post :create, params: { group_semester: {
        first_session: '2013-01-03', group_id: @group_semester.group_id,
        last_session: '2013-06-20', semester_id: semesters(:previous).id
      } }
    end

    assert_redirected_to group_semester_path(GroupSemester.last)
  end

  test 'should show group_semester' do
    get :show, params: { id: @group_semester }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @group_semester }
    assert_response :success
    assert_select 'textarea[name="group_semester[summary]"]'
  end

  test 'should update group_semester' do
    put :update, params: { id: @group_semester, group_semester: {
      first_session: @group_semester.first_session,
      group_id: @group_semester.group_id,
      last_session: @group_semester.last_session,
      semester_id: @group_semester.semester_id,
      summary: 'Practice, practice!',
    } }
    assert_redirected_to group_semester_path(@group_semester)
    @group_semester.reload
    assert_equal 'Practice, practice!', @group_semester.summary
  end

  test 'should destroy group_semester' do
    assert_difference('GroupSemester.count', -1) do
      delete :destroy, params: { id: @group_semester }
    end

    assert_redirected_to group_semesters_path
  end
end
