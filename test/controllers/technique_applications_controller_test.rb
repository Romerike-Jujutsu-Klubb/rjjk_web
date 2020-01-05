# frozen_string_literal: true

require 'controller_test'

class TechniqueApplicationsControllerTest < ActionController::TestCase
  setup do
    @technique_application = technique_applications(:defence_against_wrist_grip_in_front)
    login(:lars)
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create application' do
    assert_difference('TechniqueApplication.count') do
      post :create, params: { technique_application: {
        name: @technique_application.name + '_2',
        rank_id: @technique_application.rank_id, system: 'Goho'
      } }
    end

    assert_redirected_to edit_technique_application_path(TechniqueApplication.last)
  end

  test 'should show application' do
    get :show, params: { id: @technique_application }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @technique_application }
    assert_response :success
  end

  test 'should update application' do
    put :update, params: { id: @technique_application, technique_application: {
      name: @technique_application.name,
      rank_id: @technique_application.rank_id,
    } }
    assert_redirected_to technique_application_path(@technique_application)
  end

  test 'should destroy application' do
    assert_difference('TechniqueApplication.count', -1) do
      delete :destroy, params: { id: @technique_application }
    end

    assert_redirected_to edit_rank_path(@technique_application.rank_id)
  end
end
