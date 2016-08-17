# frozen_string_literal: true
require 'test_helper'

class PracticesControllerTest < ActionController::TestCase
  setup do
    @practice = practices(:panda_2010_42)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:practices)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create practice' do
    assert_difference('Practice.count') do
      post :create, practice: { status: @practice.status, group_schedule_id: @practice.group_schedule_id, week: @practice.week + 1, year: @practice.year }
    end

    assert_redirected_to practice_path(assigns(:practice))
  end

  test 'should show practice' do
    get :show, id: @practice
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @practice
    assert_response :success
  end

  test 'should update practice' do
    put :update, id: @practice, practice: { status: @practice.status, group_schedule_id: @practice.group_schedule_id, week: @practice.week, year: @practice.year }
    assert_redirected_to practice_path(assigns(:practice))
  end

  test 'should destroy practice' do
    assert_difference('Practice.count', -1) do
      delete :destroy, id: @practice
    end

    assert_redirected_to practices_path
  end
end
