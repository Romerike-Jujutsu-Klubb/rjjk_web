# frozen_string_literal: true

require 'controller_test'

class SurveyQuestionsControllerTest < ActionController::TestCase
  setup do
    @survey_question = survey_questions(:first_question)
    login(:uwe)
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create survey_question' do
    assert_difference('SurveyQuestion.count') do
      post :create, params: { survey_question: {
        choices: @survey_question.choices,
        free_text: @survey_question.free_text,
        survey_id: @survey_question.survey_id,
        title: @survey_question.title,
      } }
    end

    assert_redirected_to survey_question_path(SurveyQuestion.last)
  end

  test 'should show survey_question' do
    get :show, params: { id: @survey_question }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @survey_question }
    assert_response :success
  end

  test 'should update survey_question' do
    patch :update, params: { id: @survey_question, survey_question: {
      choices: @survey_question.choices,
      free_text: @survey_question.free_text,
      survey_id: @survey_question.survey_id,
      title: @survey_question.title,
    } }
    assert_redirected_to survey_question_path(@survey_question)
  end

  test 'should destroy survey_question' do
    assert_difference('SurveyQuestion.count', -1) do
      delete :destroy, params: { id: @survey_question }
    end

    assert_redirected_to survey_questions_path
  end
end
