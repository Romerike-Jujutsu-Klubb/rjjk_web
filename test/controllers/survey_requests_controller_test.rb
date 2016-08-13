require 'test_helper'

class SurveyRequestsControllerTest < ActionController::TestCase
  setup do
    @survey_request = survey_requests(:sent)
    login(:admin)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:survey_requests)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create survey_request' do
    assert_difference('SurveyRequest.count') do
      post :create, survey_request: {
              completed_at: @survey_request.completed_at,
              member_id: members(:sebastian).id,
              survey_id: @survey_request.survey_id
          }
    end

    assert_redirected_to survey_request_path(assigns(:survey_request))
  end

  test 'should show survey_request' do
    get :show, id: @survey_request
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @survey_request
    assert_response :success
  end

  test 'should update survey_request' do
    patch :update, id: @survey_request, survey_request: { completed_at: @survey_request.completed_at, member_id: @survey_request.member_id, survey_id: @survey_request.survey_id }
    assert_redirected_to survey_request_path(assigns(:survey_request))
  end

  test 'should destroy survey_request' do
    assert_difference('SurveyRequest.count', -1) do
      delete :destroy, id: @survey_request
    end

    assert_redirected_to survey_requests_path
  end

  def test_answer_form
    get :answer_form, id: survey_requests(:sent).id
    assert_response :success
  end
end
