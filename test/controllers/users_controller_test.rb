# frozen_string_literal: true

require 'controller_test'

class UsersControllerTest < ActionController::TestCase
  def test_index
    login(:admin)
    get :index
    assert_response :success
  end

  def test_show
    get :show, params: { id: login(:admin).id }
    assert_response :success
  end

  def test_edit_member
    get :edit, params: { id: login(:admin).id }
    assert_response :success
  end

  def test_edit_non_member
    login(:admin)
    get :edit, params: { id: id(:long_user) }
    assert_response :success
  end

  def test_update
    tesla = login(:admin)
    post :update, params: { id: tesla.id, user: { first_name: 'Bob', form: 'edit' } }
    tesla.reload
    assert_equal 'Bob', tesla.first_name
  end

  def test_delete
    login(:admin)
    user = users(:deletable_user)
    delete :destroy, params: { id: user.id }
    user.reload
    assert user.deleted?
    assert_not_logged_in
  end

  test 'delete_with_dependent_member' do
    user = login(:admin)
    assert_raises(ActiveRecord::DeleteRestrictionError) { delete :destroy, params: { id: user.id } }
    user.reload
    assert_not user.deleted?
  end

  private

  def assert_logged_in(user)
    assert_equal user.id, @request.session[:user_id]
  end

  def assert_not_logged_in
    assert_nil @request.session[:user_id]
  end

  def assert_redirected_to_login
    assert_equal @controller.url_for(action: 'login'), @response.redirect_url
  end
end
