# frozen_string_literal: true

require 'controller_test'

class SurveyAnswerTranslationsControllerTest < ActionController::TestCase
  setup do
    @survey_answer_translation = survey_answer_translations(:one)
    login(:admin)
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create survey_answer_translation' do
    assert_difference('SurveyAnswerTranslation.count') do
      post :create, params: { survey_answer_translation: {
        answer: @survey_answer_translation.answer,
        normalized_answer: @survey_answer_translation.normalized_answer,
      } }
    end

    assert_redirected_to survey_answer_translation_path(SurveyAnswerTranslation.last)
  end

  test 'should show survey_answer_translation' do
    get :show, params: { id: @survey_answer_translation }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @survey_answer_translation }
    assert_response :success
  end

  test 'should update survey_answer_translation' do
    patch :update, params: { id: @survey_answer_translation, survey_answer_translation: {
      answer: @survey_answer_translation.answer,
      normalized_answer: @survey_answer_translation.normalized_answer,
    } }
    assert_redirected_to survey_answer_translation_path(@survey_answer_translation)
  end

  test 'should destroy survey_answer_translation' do
    assert_difference('SurveyAnswerTranslation.count', -1) do
      delete :destroy, params: { id: @survey_answer_translation }
    end

    assert_redirected_to survey_answer_translations_path
  end
end
