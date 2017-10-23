# frozen_string_literal: true

require 'controller_test'

class SurveyAnswersControllerTest < ActionController::TestCase
  setup do
    @survey_answer = survey_answers(:one)
    login(:admin)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:survey_answers)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create survey_answer' do
    assert_difference('SurveyAnswer.count') do
      post :create, params: { survey_answer: {
        answer: @survey_answer.answer,
        survey_question_id: @survey_answer.survey_question_id,
        survey_request_id: @survey_answer.survey_request_id,
      } }
    end

    assert_redirected_to survey_answer_path(assigns(:survey_answer))
  end

  test 'should show survey_answer' do
    get :show, params: { id: @survey_answer }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @survey_answer }
    assert_response :success
  end

  test 'should update survey_answer' do
    patch :update, params: { id: @survey_answer, survey_answer: {
      answer: @survey_answer.answer,
      survey_question_id: @survey_answer.survey_question_id,
      survey_request_id: @survey_answer.survey_request_id,
    } }
    assert_redirected_to survey_answer_path(assigns(:survey_answer))
  end

  test 'should destroy survey_answer' do
    assert_difference('SurveyAnswer.count', -1) do
      delete :destroy, params: { id: @survey_answer }
    end

    assert_redirected_to survey_answers_path
  end
end
