require 'test_helper'

class CmsMembersControllerTest < ActionController::TestCase
  def setup
    login(:admin)
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:cms_members)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_cms_member
    assert_difference('CmsMember.count') do
      post :create, :cms_member => {
          :address => 'and', :first_name => 'me', :instructor => false, :last_name => 'myself', :nkf_fee => false,
          :postal_code => 'IIII', :cms_contract_id => '666', :payment_problem => false, :male => true
      }
      assert_no_errors :cms_member
    end

    assert_redirected_to cms_member_path(assigns(:cms_member))
  end

  def test_should_show_cms_member
    get :show, :id => cms_members(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => cms_members(:one).id
    assert_response :success
  end

  def test_should_update_cms_member
    put :update, :id => cms_members(:one).id, :cms_member => {}
    assert_no_errors :cms_member
    assert_redirected_to cms_member_path(assigns(:cms_member))
  end

  def test_should_destroy_cms_member
    assert_difference('CmsMember.count', -1) do
      delete :destroy, :id => cms_members(:one).id
    end

    assert_redirected_to cms_members_path
  end
end
