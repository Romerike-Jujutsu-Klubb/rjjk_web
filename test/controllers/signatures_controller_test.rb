# frozen_string_literal: true

require 'controller_test'

class SignaturesControllerTest < ActionController::TestCase
  setup do
    @signature = signatures(:lars)
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

  test 'should create signature' do
    assert_difference('Signature.count') do
      post :create, params: { signature: {
        content_type: @signature.content_type, image: 'Some image data',
        user_id: @signature.user_id, name: @signature.name
      } }
    end

    assert_redirected_to user_path(Signature.last.user, anchor: :tab_signatures_tab)
  end

  test 'should show signature' do
    get :show, params: { id: @signature }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @signature }
    assert_response :success
  end

  test 'should update signature' do
    put :update, params: { id: @signature, signature: {
      content_type: @signature.content_type, image: 'Other image data.',
      user_id: @signature.user_id, name: @signature.name
    } }
    assert_redirected_to signature_path(@signature)
  end

  test 'should destroy signature' do
    assert_difference('Signature.count', -1) do
      delete :destroy, params: { id: @signature }
    end

    assert_redirected_to user_path(@signature, anchor: :tab_signatures_tab)
  end
end
