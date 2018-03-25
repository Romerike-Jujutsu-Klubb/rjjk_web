# frozen_string_literal: true

require 'controller_test'

class NkfMembersControllerTest < ActionController::TestCase
  setup { login(:admin) }

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
      post :create, params: { nkf_member: { kjonn: 'Mann' } }
      assert_no_errors :nkf_member
    end

    assert_redirected_to nkf_member_path(assigns(:nkf_member))
  end

  test 'should show nkf_member' do
    get :show, params: { id: nkf_members(:erik).to_param }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: nkf_members(:erik).to_param }
    assert_response :success
  end

  test 'should update nkf_member' do
    put :update, params: { id: id(:erik), nkf_member: { kjonn: 'Mann' } }
    assert_redirected_to controller: :nkf_members, action: :show, id: id(:erik)
  end

  test 'should destroy nkf_member' do
    assert_difference('NkfMember.count', -1) do
      delete :destroy, params: { id: nkf_members(:erik).to_param }
    end

    assert_redirected_to nkf_members_path
  end
end
