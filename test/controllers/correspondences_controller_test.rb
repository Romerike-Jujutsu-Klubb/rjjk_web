# frozen_string_literal: true

require 'controller_test'

class CorrespondencesControllerTest < ActionController::TestCase
  setup do
    @correspondence = correspondences(:one)
  end

  test('should get index') do
    get :index
    assert_response :success
  end

  test('should get new') do
    get :new
    assert_response :success
  end

  test('should create correspondence') do
    assert_difference('Correspondence.count') do
      post :create, params: { correspondence: {
        member_id: @correspondence.member_id, related_model_id: @correspondence.related_model_id,
        sent_at: @correspondence.sent_at
      } }
    end

    assert_redirected_to correspondence_path(Correspondence.last)
  end

  test 'should show correspondence' do
    get :show, params: { id: @correspondence }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @correspondence }
    assert_response :success
  end

  test 'should update correspondence' do
    put :update, params: { id: @correspondence, correspondence: {
      member_id: @correspondence.member_id,
      related_model_id: @correspondence.related_model_id,
      sent_at: @correspondence.sent_at,
    } }
    assert_redirected_to correspondence_path(@correspondence)
  end

  test 'should destroy correspondence' do
    assert_difference('Correspondence.count', -1) do
      delete :destroy, params: { id: @correspondence }
    end

    assert_redirected_to correspondences_path
  end
end
