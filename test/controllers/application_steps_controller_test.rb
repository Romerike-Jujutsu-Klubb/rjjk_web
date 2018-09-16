# frozen_string_literal: true

require 'controller_test'

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
      post :create, params: { application_step: {
        technique_application_id: @application_step.technique_application_id,
        description: @application_step.description,
        image_attributes: {
          content_data: 'image.content_data',
          content_type: @application_step.image.content_type,
          name: @application_step.image.name,
        },
        position: 3,
      } }
      assert_no_errors :application_step
    end

    assert_redirected_to application_step_path(assigns(:application_step))
  end

  test 'should show application_step' do
    get :show, params: { id: @application_step }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @application_step }
    assert_response :success
  end

  test 'should update application_step' do
    put :update, params: { id: @application_step.id, application_step: {
      technique_application_id: @application_step.technique_application_id,
      description: @application_step.description,
      image_attributes: {
        content_data: 'content_data',
        content_type: @application_step.image.content_type,
        name: @application_step.image.name,
      },
      position: @application_step.position,
    } }
    assert_no_errors :application_step
    assert_redirected_to application_step_path(assigns(:application_step))
  end

  test 'should destroy application_step' do
    assert_difference('ApplicationStep.count(:all)', -1) do
      delete :destroy, params: { id: @application_step }
    end

    assert_redirected_to application_steps_path
  end
end
