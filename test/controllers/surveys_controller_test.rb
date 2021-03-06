# frozen_string_literal: true

require 'controller_test'

class SurveysControllerTest < ActionController::TestCase
  setup do
    @survey = surveys(:first_survey)
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

  test 'should create survey' do
    assert_difference('Survey.count') do
      post :create, params: { survey: {
        category: @survey.category,
        expires_at: @survey.expires_at,
        footer: @survey.footer,
        group_id: @survey.group_id,
        header: @survey.header,
        position: @survey.position,
        title: @survey.title,
      } }
    end

    assert_redirected_to survey_path(Survey.last)
  end

  test 'should show survey' do
    get :show, params: { id: @survey }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @survey }
    assert_response :success
  end

  test 'should update survey' do
    patch :update, params: { id: @survey, survey: {
      category: @survey.category,
      expires_at: @survey.expires_at,
      footer: @survey.footer,
      group_id: @survey.group_id,
      header: @survey.header,
      position: @survey.position,
      title: @survey.title,
    } }
    assert_redirected_to survey_path(@survey)
  end

  test 'should destroy survey' do
    assert_difference('Survey.count', -1) do
      delete :destroy, params: { id: @survey }
    end

    assert_redirected_to surveys_path
  end
end
