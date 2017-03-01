# frozen_string_literal: true
require 'test_helper'

class BirthdayCelebrationsControllerTest < ActionController::TestCase
  setup do
    @birthday_celebration = birthday_celebrations(:one)
    login(:admin)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:birthday_celebrations)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create birthday_celebration' do
    assert_difference('BirthdayCelebration.count') do
      post :create, params:{birthday_celebration: {
          held_on: @birthday_celebration.held_on,
          participants: @birthday_celebration.participants,
      }}
      assert_no_errors :birthday_celebration
    end

    assert_redirected_to birthday_celebration_path(assigns(:birthday_celebration))
  end

  test 'should show birthday_celebration' do
    get :show, params:{id: @birthday_celebration}
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params:{id: @birthday_celebration}
    assert_response :success
  end

  test 'should update birthday_celebration' do
    put :update, params:{id: @birthday_celebration, birthday_celebration: {
        held_on: @birthday_celebration.held_on,
        participants: @birthday_celebration.participants,
    }}
    assert_redirected_to birthday_celebration_path(assigns(:birthday_celebration))
  end

  test 'should destroy birthday_celebration' do
    assert_difference('BirthdayCelebration.count', -1) do
      delete :destroy, params:{id: @birthday_celebration}
    end

    assert_redirected_to birthday_celebrations_path
  end
end
