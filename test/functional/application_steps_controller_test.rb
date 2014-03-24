require 'test_helper'

class ApplicationStepsControllerTest < ActionController::TestCase
  setup do
    @application_step = application_steps(:one)
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
    assert_difference('ApplicationStep.count') do
      post :create, application_step: {
          technique_application_id: @application_step.technique_application_id,
          description: @application_step.description,
          image_content_data: @application_step.image_content_data,
          image_content_type: @application_step.image_content_type,
          image_filename: @application_step.image_filename,
          position: 3}
      assert_no_errors :application_step
    end

    assert_redirected_to application_step_path(assigns(:application_step))
  end

  test 'should show application_step' do
    get :show, id: @application_step
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @application_step
    assert_response :success
  end

  test 'should update application_step' do
    put :update, id: @application_step, application_step: {
        technique_application_id: @application_step.technique_application_id,
        description: @application_step.description,
        image_content_data: @application_step.image_content_data,
        image_content_type: @application_step.image_content_type,
        image_filename: @application_step.image_filename,
        position: @application_step.position}
    assert_no_errors :application_step
    assert_redirected_to application_step_path(assigns(:application_step))
  end

  test 'should destroy application_step' do
    assert_difference('ApplicationStep.count', -1) do
      delete :destroy, id: @application_step
    end

    assert_redirected_to application_steps_path
  end
end
