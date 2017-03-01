# frozen_string_literal: true
require 'test_helper'

class ApplicationStepsControllerTest < ActionController::TestCase
  setup do
    @application_step = application_steps(:one)
    login(:lars)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:application_steps)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create application_step' do
    assert_difference('ApplicationStep.count(:all)') do
      post :create, params:{application_step: {
          technique_application_id: @application_step.technique_application_id,
          description: @application_step.description,
          image_content_data: @application_step.image_content_data,
          image_content_type: @application_step.image_content_type,
          image_filename: @application_step.image_filename,
          position: 3,
      }}
      assert_no_errors :application_step
    end

    assert_redirected_to application_step_path(assigns(:application_step))
  end

  test 'should show application_step' do
    get :show, params:{id: @application_step}
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params:{id: @application_step}
    assert_response :success
  end

  test 'should update application_step' do
    put :update, params:{id: @application_step, application_step: {
        technique_application_id: @application_step.technique_application_id,
        description: @application_step.description,
        image_content_data: @application_step.image_content_data,
        image_content_type: @application_step.image_content_type,
        image_filename: @application_step.image_filename,
        position: @application_step.position,
    }}
    assert_no_errors :application_step
    assert_redirected_to application_step_path(assigns(:application_step))
  end

  test 'should destroy application_step' do
    assert_difference('ApplicationStep.count(:all)', -1) do
      delete :destroy, params:{id: @application_step}
    end

    assert_redirected_to application_steps_path
  end

  test 'should hide image from public user' do
    logout
    get :image, params:{id: @application_step}
    assert_response :redirect
    assert_redirected_to login_path
  end

  test 'should show image to unranked member' do
    login :newbie
    get :image, params:{id: @application_step}
    assert_response :success
  end

  test 'should hide high-rank image from unranked member' do
    login :newbie
    get :image, params:{id: application_steps(:defence_against_dual_hair_grip_with_kneeing_step_1)}
    assert_redirected_to login_path
  end

  test 'should show image to ranked member' do
    login :lars
    get :image, params:{id: @application_step}
    assert_response :success
  end

  test 'should redirect to dummy image if no image content' do
    login :lars
    get :image, params: {id: application_steps(:two).id}
    assert_response :redirect
    assert_redirected_to '/assets/pdficon_large.png'
  end
end
