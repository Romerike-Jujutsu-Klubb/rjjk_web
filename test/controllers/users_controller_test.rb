# frozen_string_literal: true

require 'controller_test'

class UsersControllerTest < ActionController::TestCase
  def test_index
    login(:uwe)
    get :index
    assert_response :success
  end

  test 'should create user' do
    login(:uwe)
    assert_difference('User.count') do
      post :create, params: { user: {
        first_name: 'Uwe',
        last_name: 'Seeler',
        email: 'uwe@seeler.de',
        phone: '3178',
      } }
    end
    assert_redirected_to user_path(User.last)
  end

  def test_show
    get :show, params: { id: login(:uwe).id }
    assert_response :success
  end

  def test_show_vcf
    get :show, params: { id: login(:uwe).id }, format: :vcf
    assert_response :success
  end

  def test_photo
    uwe = login(:uwe)
    get :photo, params: { id: uwe.id }
    assert_redirected_to uwe.member.image
  end

  def test_edit_member
    get :edit, params: { id: login(:uwe).id }
    assert_response :success
  end

  def test_edit_non_member
    login(:uwe)
    get :edit, params: { id: id(:long_user) }
    assert_response :success
  end

  def test_update
    tesla = login(:uwe)
    post :update, params: { id: tesla.id, user: { first_name: 'Bob', form: 'edit' } }
    tesla.reload
    assert_equal 'Bob', tesla.first_name
  end

  def test_delete
    login(:uwe)
    user = users(:deletable_user)
    delete :destroy, params: { id: user.id }
    user.reload
    assert user.deleted?
    assert_not_logged_in
  end

  test 'delete_with_dependent_member' do
    user = login(:uwe)
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
