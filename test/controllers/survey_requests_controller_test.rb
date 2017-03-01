# frozen_string_literal: true
require 'test_helper'

class SurveyRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @survey_request = survey_requests(:sent)
    login(:admin)
  end

  test 'should get index' do
    get survey_requests_path
    assert_response :success
  end

  test 'should get new' do
    get new_survey_request_url
    assert_response :success
  end

  test 'should create survey_request' do
    assert_difference('SurveyRequest.count') do
      post survey_requests_url, params: { survey_request: {
          completed_at: @survey_request.completed_at,
              member_id: members(:sebastian).id,
              survey_id: @survey_request.survey_id,
      } }
    end

    assert_redirected_to SurveyRequest.last
  end

  test 'should show survey_request' do
    get survey_request_url(@survey_request)
    assert_response :success
  end

  test 'should get edit' do
    get edit_survey_request_url(@survey_request)
    assert_response :success
  end

  test 'should update survey_request' do
    patch survey_request_url(@survey_request), params: { survey_request: {
        completed_at: @survey_request.completed_at,
        member_id: @survey_request.member_id,
        survey_id: @survey_request.survey_id,
    } }
    assert_redirected_to survey_request_url(@survey_request)
  end

  test 'should destroy survey_request' do
    assert_difference('SurveyRequest.count', -1) do
      delete survey_request_url(@survey_request)
    end

    assert_redirected_to survey_requests_path
  end

  def test_answer_form
    get "/svar/#{survey_requests(:sent).id}"
    assert_response :success
    assert_match(/val\(\) && /, response.body)
  end
end
