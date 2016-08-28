# frozen_string_literal: true
require 'test_helper'

class SurveyAnswerTranslationsControllerTest < ActionController::TestCase
  setup do
    @survey_answer_translation = survey_answer_translations(:one)
    login(:admin)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:survey_answer_translations)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create survey_answer_translation' do
    assert_difference('SurveyAnswerTranslation.count') do
      post :create, survey_answer_translation: {
          answer: @survey_answer_translation.answer,
          normalized_answer: @survey_answer_translation.normalized_answer,
      }
      assert_no_errors :survey_answer_translation
    end

    assert_redirected_to survey_answer_translation_path(assigns(:survey_answer_translation))
  end

  test 'should show survey_answer_translation' do
    get :show, id: @survey_answer_translation
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @survey_answer_translation
    assert_response :success
  end

  test 'should update survey_answer_translation' do
    patch :update, id: @survey_answer_translation, survey_answer_translation: {
        answer: @survey_answer_translation.answer,
        normalized_answer: @survey_answer_translation.normalized_answer,
    }
    assert_redirected_to survey_answer_translation_path(assigns(:survey_answer_translation))
  end

  test 'should destroy survey_answer_translation' do
    assert_difference('SurveyAnswerTranslation.count', -1) do
      delete :destroy, id: @survey_answer_translation
      assert_no_errors :survey_answer_translation
    end

    assert_redirected_to survey_answer_translations_path
  end
end
