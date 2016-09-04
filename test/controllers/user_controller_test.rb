# frozen_string_literal: true
require 'test_helper'

class UserControllerTest < ActionController::TestCase
  def test_login__valid_login__redirects_as_specified
    add_stored_detour controller: :welcome, action: :index
    post :login, user: { login: 'lars', password: 'atest' }
    assert_logged_in users(:lars)
    assert_response :redirect
    assert_redirected_to controller: :welcome, action: :index
  end

  def test_login_with_remember_me
    post :login, user: { login: 'lars', password: 'atest' }, remember_me: '1'

    assert_logged_in users(:lars)
    assert_response :redirect
    assert_equal @controller.url_for(controller: :welcome, action: :index, only_path: false),
        @response.redirect_url
    assert cookies[:token]
    assert_not_equal 'random_token_string', cookies[:token]
    assert_equal false, users(:lars).token_expired?
    assert_not_equal 'random_token_string', users(:lars).security_token
  end

  def test_autologin_with_token
    @request.cookies['token'] = 'random_token_string'
    get :welcome
    assert_response :ok
    assert_logged_in users(:lars)
  end

  def test_login__valid_login__shows_welcome_as_default
    post :login, user: { login: 'lars', password: 'atest' }
    assert_logged_in users(:lars)
    assert_response :redirect
    assert_equal @controller.url_for(controller: :welcome, action: :index, only_path: false),
        @response.redirect_url
  end

  def test_login__wrong_password
    post :login, user: { login: 'lars', password: 'wrong password' }
    assert_not_logged_in
    assert_template 'login'
    assert_contains 'Innlogging feilet.', flash['message']
  end

  def test_login__wrong_login
    post :login, user: { login: 'wrong login', password: 'atest' }
    assert_not_logged_in
    assert_template 'login'
    assert_contains 'Innlogging feilet.', flash['message']
  end

  def test_login__deleted_user_cant_login
    post :login, user: { login: 'deleted_tesla', password: 'atest' }
    assert_not_logged_in
    assert_template 'login'
    assert_contains 'Innlogging feilet.', flash['message']
  end

  def test_signup
    post_signup login: 'newuser',
                password: 'password', password_confirmation: 'password',
                email: 'newemail@example.com'
    assert_not_logged_in
    assert_redirected_to_login
    assert_equal 1, UserMessage.pending.size

    mail = UserMessage.pending[0]
    assert_equal ['"newuser" <newemail@example.com>'], mail.to
    assert_match(/Brukernavn:\s+\w+\n/, mail.body)
    assert_match(/Passord\s*:\s+\w+\n/, mail.body)
    user = User.find_by_email('newemail@example.com')
    assert_match(/key=#{user.security_token}/, mail.body)
    assert !user.verified
  end

  def test_signup__cannot_set_arbitrary_attributes
    post_signup login: 'newuser',
        password: 'password', password_confirmation: 'password',
        email: 'skunk@example.com',
        verified: '1',
        role: 'superadmin'
    user = User.find_by_email('skunk@example.com')
    assert !user.verified
    assert_nil user.role
  end

  def test_signup__validates_password_min_length
    post_signup login: 'tesla_rhea', password: 'bad', password_confirmation: 'bad',
        email: 'someone@example.com'
    assert_password_validation_fails
  end

  def test_signup__mismatched_passwords
    post :signup, user: { login: 'newtesla', password: 'newpassword', password_confirmation: 'wrong' }
    user = assigns(:user)
    assert_equal 1, user.errors.size
    assert_not_nil user.errors['password']
  end

  def test_signup__bad_login
    post_signup login: 'yo', password: 'newpassword', password_confirmation: 'newpassword'
    user = assigns(:user)
    assert_equal 1, user.errors.size
    assert_not_nil user.errors['login']
  end

  def test_welcome
    user = users(:unverified_user)
    get :welcome, user: { id: user.id }, key: user.security_token
    user.reload
    assert user.verified
    assert_logged_in(user)
  end

  def test_welcome__fails_if_expired_token
    user = users(:unverified_user)
    Timecop.freeze(Time.now + User.token_lifetime) do # now past verification deadline
      get :welcome, user: { id: user.id }, key: user.security_token
      user.reload
      assert !user.verified
      assert_not_logged_in
    end
  end

  def test_welcome__fails_if_bad_token
    user = users(:unverified_user)
    get :welcome, user: { id: user.id }, key: 'boguskey'
    user.reload
    assert !user.verified
    assert_not_logged_in
  end

  def test_edit
    tesla = login(:admin)
    post :update, user: { first_name: 'Bob', form: 'edit' }
    tesla.reload
    assert_equal 'Bob', tesla.first_name
  end

  def test_delete
    user = login(:admin)
    post :update, 'user' => { 'form' => 'delete' }
    user.reload
    assert user.deleted
    assert_not_logged_in
  end

  def test_change_password
    user = login(:lars)
    post :change_password, user: { password: 'changed_password', password_onfirmation: 'changed_password' }
    assert_no_errors :user
    assert_equal 1, UserMessage.pending.size
    mail = UserMessage.pending[0]
    assert_equal ['"Lars Bråten" <lars@example.com>'], mail.to
    assert_equal user, User.authenticate(user.login, 'changed_password')
  end

  def test_change_password__confirms_password
    login(:lars)
    post :change_password, user: { password: 'bad', password_confirmation: 'bad' }
    user = assigns(:user)
    assert_equal 1, user.errors.size
    assert_not_nil user.errors['password']
    assert_response :success
    assert_equal 0, UserMessage.pending.size
  end

  def test_forgot_password__when_logged_in_redirects_to_change_password
    user = login(:lars)
    post :forgot_password, user: { email: user.email }
    assert_equal 0, UserMessage.pending.size
    assert_response :redirect
    assert_equal @controller.url_for(action: 'change_password'), @response.redirect_url
  end

  def test_forgot_password__requires_valid_email_address
    post :forgot_password, user: { email: '' }
    assert_equal 0, UserMessage.pending.size
    assert_match(/Skriv inn en gyldig e-postadresse./, @response.body)
  end

  def test_forgot_password__ignores_unknown_email_address
    post :forgot_password, user: { email: 'unknown_email@example.com' }
    assert_equal 0, UserMessage.pending.size
  end

  def test_invalid_login
    post :login, user: { login: 'lars', password: 'not_correct' }
    assert_not_logged_in
    assert_response :success
    assert_template 'login'
  end

  def test_logout
    login(:lars)
    get :logout
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

  def post_signup(user_params)
    post :signup, 'user' => user_params
  end

  def assert_password_validation_fails
    user = assigns(:user)
    assert_equal 1, user.errors.size
    assert_not_nil user.errors['password']
    assert_response :success
    assert_equal 0, UserMessage.pending.size
  end

  def assert_contains(target, container)
    assert !container.nil?, %( Failed to find "#{target}" in nil String )
    assert container.include?(target), "#{container.inspect} does not contain #{target.inspect}"
  end
end
