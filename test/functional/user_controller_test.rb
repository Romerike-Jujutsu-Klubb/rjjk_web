require File.dirname(__FILE__) + '/../test_helper'
require 'user_controller'
require 'user_notify'

# Raise errors beyond the default web-based presentation
class UserController; def rescue_action(e) raise e end; end

class UserControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = false
  fixtures :users

  def setup
    @controller = UserController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "localhost"
    Mail::TestMailer.inject_one_error = false
    Mail::TestMailer.deliveries = []
  end
  
  def test_login__valid_login__redirects_as_specified
    add_stored_detour :controller => :welcome, :action => :index
    post :login, :user => { :login => "tesla", :password => "atest" }
    assert_logged_in users(:tesla)
    assert_response :redirect
    assert_redirected_to :controller => :welcome, :action => :index
  end

  def test_login_with_remember_me
    post :login, :user => { :login => "tesla", :password => "atest"}, :remember_me => '1'
    
    assert_logged_in users(:tesla)
    assert_response :redirect
    assert_equal @controller.url_for(:controller => :welcome, :action => :index, :only_path => false), @response.redirect_url
    assert_equal cookies[:autologin], '1000001'
    assert cookies[:token]
    assert_not_equal 'random_token_string', cookies[:token]
    assert_equal false, User.find(1000001).token_expired?
    assert_not_equal 'random_token_string', User.find(1000001).security_token
  end
  
  def test_autologin_with_token
    @request.cookies['autologin'] = CGI::Cookie.new('autologin', '1000001')
    @request.cookies['token']     = CGI::Cookie.new('token'    , 'random_token_string')
#    @request.cookies['autologin'] = '1000001'
#    @request.cookies['token'] = 'random_token_string'
    get :welcome
    assert_logged_in users(:tesla)
    assert_response :ok
  end
  
  def test_login__valid_login__shows_welcome_as_default
    post :login, :user => { :login => "tesla", :password => "atest" }
    assert_logged_in users(:tesla)
    assert_response :redirect
    assert_equal @controller.url_for(:controller => :welcome, :action => :index, :only_path => false),
                 @response.redirect_url
  end

  def test_login__wrong_password
    post :login, :user => { :login => "tesla", :password => "wrong password" }
    assert_not_logged_in
    assert_template 'login'
    assert_contains "Login failed", flash['message']
  end

  def test_login__wrong_login
    post :login, :user => { :login => "wrong login", :password => "atest" }
    assert_not_logged_in
    assert_template 'login'
    assert_contains "Login failed", flash['message']
  end

  def test_login__deleted_user_cant_login
    post :login, :user => { :login => "deleted_tesla", :password => "atest" }
    assert_not_logged_in
    assert_template 'login'
    assert_contains "Login failed", flash['message']
  end
  
  def test_signup
    post_signup :login => "newuser",
                :password => "password", :password_confirmation => "password",
                :email => "newemail@example.com"
    assert_not_logged_in
    assert_redirected_to_login
    assert_equal 1, Mail::TestMailer.deliveries.size

    mail = Mail::TestMailer.deliveries[0]
    assert_equal "uwe@kubosch.no", mail.to_addrs[0].to_s
    assert_match /Brukernavn:\s+\w+\r\n/, mail.encoded
    assert_match /Passord\s*:\s+\w+\r\n/, mail.encoded
    user = User.find_by_email("newemail@example.com")
    assert_match /user\[id\]=3D#{user.id}/, mail.encoded
    assert_match /key=#{user.security_token}/, mail.body.decoded
    assert !user.verified
  end

  def test_signup__cannot_set_arbitrary_attributes
    post_signup :login => "newuser",
                :password => "password", :password_confirmation => "password",
                :email => "skunk@example.com",
                :verified => '1',
                :role => 'superadmin'
    user = User.find_by_email("skunk@example.com")
    assert !user.verified
    assert_nil user.role
  end

  def test_signup__validates_password_min_length
    post_signup :login => "tesla_rhea", :password => "bad", :password_confirmation => "bad", :email => "someone@example.com"
    assert_password_validation_fails
  end

  def test_signup__raises_delivery_errors
    Mail::TestMailer.inject_one_error = true
    post_signup :login => "newtesla",
                :password => "newpassword", :password_confirmation => "newpassword",
                :email => "newtesla@example.com"
    assert_not_logged_in
    assert_equal 0, Mail::TestMailer.deliveries.size
    assert_contains "confirmation email not sent", flash['message']
  end

  def test_signup__mismatched_passwords
    post :signup, :user => { :login => "newtesla", :password => "newpassword", :password_confirmation => "wrong" }
    user = assigns(:user)
    assert_equal 1, user.errors.size
    assert_not_nil user.errors['password']
  end
  
  def test_signup__bad_login
    post_signup :login => "yo", :password => "newpassword", :password_confirmation => "newpassword"
    user = assigns(:user)
    assert_equal 1, user.errors.size
    assert_not_nil user.errors['login']
  end

  def test_welcome
    user = users(:unverified_user)
    get :welcome, :user=> { :id => user.id }, :key => user.security_token
    user.reload
    assert user.verified
    assert_logged_in( user )
    assert user.token_expired?
  end

  def test_welcome__fails_if_expired_token
    user = users(:unverified_user)
    Clock.advance_by_seconds User.token_lifetime # now past verification deadline
    get :welcome, :user=> { :id => user.id }, :key => user.security_token
    user.reload
    assert !user.verified
    assert_not_logged_in
  end

  def test_welcome__fails_if_bad_token
    user = users(:unverified_user)
    Clock.time = Time.now # now before deadline, but with bad token
    get :welcome, :user=> { :id => user.id }, :key => "boguskey"
    user.reload
    assert !user.verified
    assert_not_logged_in
  end

  def test_edit
    tesla = users(:admin)
    set_logged_in tesla
    post :edit, :user => { :first_name => "Bob", :form => "edit" }
    tesla.reload
    assert_equal "Bob", tesla.first_name
  end

  def test_delete
    user = users(:deletable_user)
    user = users(:admin)
    set_logged_in user
    post :edit, "user" => { "form" => "delete" }
    user.reload
    assert user.deleted
    assert_not_logged_in
  end

  def test_change_password
    user = users(:tesla)
    set_logged_in user
    post :change_password, :user => { :password => "changed_password", :password_onfirmation => "changed_password" }
    assert_no_errors :user
    assert_equal 1, Mail::TestMailer.deliveries.size
    mail = Mail::TestMailer.deliveries[0]
    assert_equal "uwe@kubosch.no", mail.to_addrs[0].to_s
    assert_match /brukernavn:\s+\w+ eller [a-zA-Z0-9.@]+\r\n/, mail.encoded
    assert_match /passord\s*:\s+\w+\r\n/, mail.encoded
    assert_equal user, User.authenticate(user.login, 'changed_password')
  end

  def test_change_password__confirms_password
    set_logged_in users(:tesla)
    post :change_password, :user => { :password => "bad", :password_confirmation => "bad" }
    user = assigns(:user)
    assert_equal 1, user.errors.size
    assert_not_nil user.errors['password']
    assert_response :success
    assert_equal 0, Mail::TestMailer.deliveries.size
  end

  def test_change_password__succeeds_despite_delivery_errors
    set_logged_in users(:tesla)
    Mail::TestMailer.inject_one_error = true
    post :change_password, :user => { :password => "changed_password", :password_confirmation => "changed_password" }
    assert_equal 0, Mail::TestMailer.deliveries.size
    assert_equal users(:tesla), User.authenticate(users(:tesla).login, 'changed_password')
  end

  def test_forgot_password__when_logged_in_redirects_to_change_password
    user = users(:tesla)
    set_logged_in user
    post :forgot_password, :user => { :email => user.email }
    assert_equal 0, Mail::TestMailer.deliveries.size
    assert_response :redirect
    assert_equal @controller.url_for(:action => "change_password"), @response.redirect_url
  end

  def test_forgot_password__requires_valid_email_address
    post :forgot_password, :user => { :email => "" }
    assert_equal 0, Mail::TestMailer.deliveries.size
    assert_match /Please enter a valid email address./, @response.body
  end

  def test_forgot_password__ignores_unknown_email_address
    post :forgot_password, :user => { :email => "unknown_email@example.com" }
    assert_equal 0, Mail::TestMailer.deliveries.size
  end

  def test_forgot_password__reports_delivery_error
    Mail::TestMailer.inject_one_error = true
    post :forgot_password, :user => { :email => users(:tesla).email }
    assert_equal 0, Mail::TestMailer.deliveries.size
    assert_match /Your password could not be emailed/, @response.body
  end

  def test_invalid_login
    post :login, :user => { :login => "tesla", :password => "not_correct" }
    assert_not_logged_in
    assert_response :success
    assert_template 'login'
  end
  
  def test_logout
    set_logged_in users(:tesla)
    get :logout
    assert_not_logged_in
  end

  private

  def set_logged_in( user )
    @request.session[:user_id] = user.id
  end

  def assert_logged_in( user )
    assert_equal user.id, @request.session[:user_id]
  end

  def assert_not_logged_in
    assert_nil @request.session[:user_id]
    assert_nil assigns(:current_user)
  end

  def assert_redirected_to_login
    assert_equal @controller.url_for(:action => "login"), @response.redirect_url
  end

  def post_signup( user_params )
    post :signup, "user" => user_params
  end

  def assert_password_validation_fails
    user = assigns(:user)
    assert_equal 1, user.errors.size
    assert_not_nil user.errors['password']
    assert_response :success
    assert_equal 0, Mail::TestMailer.deliveries.size
  end

  def assert_contains( target, container )
    assert !container.nil?, %Q( Failed to find "#{target}" in nil String )
    assert container.include?(target), "#{container.inspect} does not contain #{target.inspect}"
  end

end
