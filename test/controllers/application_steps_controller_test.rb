# frozen_string_literal: true

require 'integration_test'

class ApplicationStepsControllerTest < IntegrationTest
  setup do
    @application_step = application_steps(:one)
    login(:lars)
  end

  test 'should get index' do
    get application_steps_path
    assert_response :success
  end

  test 'should get new' do
    get new_application_step_path
    assert_response :success
  end

  test 'should create application_step' do
    assert_difference('ApplicationStep.count(:all)') do
      post application_steps_path, params: { application_step: {
        technique_application_id: @application_step.technique_application_id,
        description: @application_step.description,
        image_attributes: {
          content_data: 'image.content_data',
          content_type: @application_step.image.content_type,
          name: @application_step.image.name,
        },
        position: 3,
      } }
    end

    assert_redirected_to edit_technique_application_path(@application_step.technique_application_id)
  end

  test 'should show application_step' do
    get application_step_path(@application_step)
    assert_response :success
  end

  test 'should get edit' do
    get edit_application_step_path(@application_step)
    assert_response :success
  end

  test 'should update application_step' do
    put application_step_path(@application_step), params: { application_step: {
      technique_application_id: @application_step.technique_application_id,
      description: @application_step.description,
      image_attributes: {
        content_data: 'content_data',
        content_type: @application_step.image.content_type,
        name: @application_step.image.name,
      },
      position: @application_step.position,
    } }
    assert_redirected_to application_step_path(@application_step)
  end

  test 'should destroy application_step' do
    assert_difference('ApplicationStep.count(:all)', -1) do
      delete application_step_path(@application_step)
    end

    assert_redirected_to application_steps_path
  end
end
