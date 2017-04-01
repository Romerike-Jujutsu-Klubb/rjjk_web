# frozen_string_literal: true

require 'test_helper'

class TechniqueApplicationsControllerTest < ActionController::TestCase
  setup do
    @technique_application = technique_applications(:defence_against_wrist_grip_in_front)
    login(:lars)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:technique_applications)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create application' do
    assert_difference('TechniqueApplication.count') do
      post :create, params:{technique_application: {
          name: @technique_application.name + '_2',
          rank_id: @technique_application.rank_id, system: 'Goho'
      }}
      assert_no_errors :technique_application
    end

    assert_redirected_to technique_application_path(assigns(:technique_application))
  end

  test 'should show application' do
    get :show, params:{id: @technique_application}
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params:{id: @technique_application}
    assert_response :success
  end

  test 'should update application' do
    put :update, params:{id: @technique_application, technique_application: {
        name: @technique_application.name,
        rank_id: @technique_application.rank_id,
    }}
    assert_redirected_to technique_application_path(assigns(:technique_application))
  end

  test 'should destroy application' do
    assert_difference('TechniqueApplication.count', -1) do
      delete :destroy, params:{id: @technique_application}
    end

    assert_redirected_to technique_applications_path
  end
end
