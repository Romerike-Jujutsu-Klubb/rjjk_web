# frozen_string_literal: true
require 'test_helper'

class SignaturesControllerTest < ActionController::TestCase
  setup do
    @signature = signatures(:lars)
    login(:admin)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:signatures)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create signature' do
    assert_difference('Signature.count') do
      post :create, signature: {
          content_type: @signature.content_type, image: @signature.image,
          member_id: @signature.member_id, name: @signature.name
      }
      assert_no_errors :signature
    end

    assert_redirected_to signature_path(assigns(:signature))
  end

  test 'should show signature' do
    get :show, id: @signature
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @signature
    assert_response :success
  end

  test 'should update signature' do
    put :update, id: @signature, signature: {
        content_type: @signature.content_type, image: @signature.image,
        member_id: @signature.member_id, name: @signature.name
    }
    assert_redirected_to signature_path(assigns(:signature))
  end

  test 'should destroy signature' do
    assert_difference('Signature.count', -1) do
      delete :destroy, id: @signature
    end

    assert_redirected_to signatures_path
  end
end
