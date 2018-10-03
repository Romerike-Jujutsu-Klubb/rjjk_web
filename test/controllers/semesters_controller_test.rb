# frozen_string_literal: true

require 'controller_test'

class SemestersControllerTest < ActionController::TestCase
  setup do
    @semester = semesters(:previous)
    login(:admin)
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create semester' do
    assert_difference('Semester.count') do
      post :create, params: { semester: { end_on: @semester.end_on, start_on: @semester.start_on } }
    end

    assert_redirected_to semester_path(Semester.last)
  end

  test 'should show semester' do
    get :show, params: { id: @semester }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @semester }
    assert_response :success
  end

  test 'should update semester' do
    put :update, params: { id: @semester, semester: { end_on: @semester.end_on, start_on: @semester.start_on } }
    assert_redirected_to semester_path(@semester)
  end

  test 'should destroy semester' do
    assert_difference('Semester.count', -1) do
      delete :destroy, params: { id: @semester }
    end

    assert_redirected_to semesters_path
  end
end
