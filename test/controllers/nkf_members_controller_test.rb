# frozen_string_literal: true
require File.dirname(__FILE__) + '/../test_helper'

class NkfMembersControllerTest < ActionController::TestCase
  def setup
    login(:admin)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:nkf_members)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create nkf_member' do
    assert_difference('NkfMember.count') do
      post :create, nkf_member: { kjonn: 'Mann' }
      assert_no_errors :nkf_member
    end

    assert_redirected_to nkf_member_path(assigns(:nkf_member))
  end

  test 'should show nkf_member' do
    get :show, id: nkf_members(:erik).to_param
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: nkf_members(:erik).to_param
    assert_response :success
  end

  test 'should update nkf_member' do
    put :update, id: nkf_members(:erik).to_param, nkf_member: {}
    assert_redirected_to controller: :nkf_members, action: :comparison, id: 0
  end

  test 'should destroy nkf_member' do
    assert_difference('NkfMember.count', -1) do
      delete :destroy, id: nkf_members(:erik).to_param
    end

    assert_redirected_to nkf_members_path
  end
end
