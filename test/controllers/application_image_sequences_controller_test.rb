# frozen_string_literal: true

require 'test_helper'

class ApplicationImageSequencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @application_image_sequence = application_image_sequences(:one)
    login
  end

  test 'should get index' do
    get application_image_sequences_url
    assert_response :success
  end

  test 'should get new' do
    get new_application_image_sequence_url
    assert_response :success
  end

  test 'should create application_image_sequence' do
    assert_difference('ApplicationImageSequence.count') do
      post application_image_sequences_url, params: { application_image_sequence: {
        position: @application_image_sequence.position + 1,
        technique_application_id: @application_image_sequence.technique_application_id,
        title: @application_image_sequence.title,
      } }
    end

    assert_redirected_to application_image_sequence_url(ApplicationImageSequence.last)
  end

  test 'should show application_image_sequence' do
    get application_image_sequence_url(@application_image_sequence)
    assert_response :success
  end

  test 'should get edit' do
    get edit_application_image_sequence_url(@application_image_sequence)
    assert_response :success
  end

  test 'should update application_image_sequence' do
    patch application_image_sequence_url(@application_image_sequence), params: { application_image_sequence: {
      position: @application_image_sequence.position,
      technique_application_id: @application_image_sequence.technique_application_id,
      title: @application_image_sequence.title,
    } }
    assert_redirected_to application_image_sequence_url(@application_image_sequence)
  end

  test 'should destroy application_image_sequence' do
    assert_difference('ApplicationImageSequence.count', -1) do
      delete application_image_sequence_url(@application_image_sequence)
    end

    assert_redirected_to application_image_sequences_url
  end
end
