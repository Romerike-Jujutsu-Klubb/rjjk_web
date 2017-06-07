# frozen_string_literal: true

require 'test_helper'

class RawIncomingEmailsControllerTest < ActionController::TestCase
  setup do
    @raw_incoming_email = raw_incoming_emails(:kasserer)
    login :admin
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:raw_emails)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create raw_incoming_email' do
    assert_difference('RawIncomingEmail.count') do
      post :create, params:{ raw_incoming_email: { content: @raw_incoming_email.content } }
    end

    assert_redirected_to raw_incoming_email_path(assigns(:raw_incoming_email))
  end

  test 'should show raw_incoming_email' do
    get :show, params:{ id: @raw_incoming_email }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params:{ id: @raw_incoming_email }
    assert_response :success
  end

  test 'should update raw_incoming_email' do
    patch :update, params:{ id: @raw_incoming_email, raw_incoming_email: {
        content: @raw_incoming_email.content,
    } }
    assert_redirected_to raw_incoming_email_path(assigns(:raw_incoming_email))
  end

  test 'should destroy raw_incoming_email' do
    assert_difference('RawIncomingEmail.count', -1) do
      delete :destroy, params:{ id: @raw_incoming_email }
    end

    assert_redirected_to raw_incoming_emails_path
  end
end
