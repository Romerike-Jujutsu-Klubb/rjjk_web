# frozen_string_literal: true
require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def test_index
    get :index
  end

  def test_edit
    tesla = login(:admin)
    post :update, params:{id: tesla.id, user: { first_name: 'Bob', form: 'edit' }}
    tesla.reload
    assert_equal 'Bob', tesla.first_name
  end

  def test_delete
    user = login(:admin)
    post :update, params: { id: user.id, user: {form: 'delete' }}
    user.reload
    assert user.deleted
    assert_not_logged_in
  end

  private

  def assert_logged_in(user)
    assert_equal user.id, @request.session[:user_id]
  end

  def assert_not_logged_in
    assert_nil @request.session[:user_id]
    assert_nil assigns(:current_user)
  end

  def assert_redirected_to_login
    assert_equal @controller.url_for(action: 'login'), @response.redirect_url
  end
end
