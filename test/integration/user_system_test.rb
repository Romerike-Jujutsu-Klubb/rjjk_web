require File.dirname(__FILE__) + '/../test_helper'
require 'user_controller'
require 'user_notify'

class UserSystemTest < ActionController::IntegrationTest
  self.use_transactional_fixtures = false
  fixtures :users

  def setup
    Mail::TestMailer.inject_one_error = false
    Mail::TestMailer.deliveries = []
  end

  def test_signup_and_verify
    Clock.time = Time.now
    post url_for(:controller => 'user', :action => 'signup'),
         :user => {:login => 'newuser',
                   :password => 'password', :password_confirmation => 'password',
                   :email => 'newemail@example.com'}

    assert_not_logged_in
    assert_redirected_to_login
    assert_equal 1, Mail::TestMailer.deliveries.size

    mail = Mail::TestMailer.deliveries[0]
    assert_equal 'uwe@kubosch.no', mail.to_addrs[0].to_s
    assert_match(/Brukernavn:\s+\w+\r\n/, mail.encoded)
    assert_match(/Passord\s*:\s+\w+\r\n/, mail.encoded)
    assert (mail.decoded =~ /key=(.*?)"/)
    key = $1

    Clock.advance_by_seconds User.token_lifetime # now past verification deadline

    get url_for(:controller => 'user', :action => 'welcome'), :key => key
    assert_redirected_to_login
    assert user = User.find_by_login('newuser')
    assert !user.verified
    assert_not_logged_in

    Clock.time = Time.now # now before deadline
    get url_for(:controller => 'user', :action => 'welcome'), :key => 'boguskey'
    assert_redirected_to_login
    assert_not_logged_in
    user.reload
    assert !user.verified

    get url_for(:controller => 'user', :action => 'welcome'), :key => "#{key}"
    assert_response :success
    user.reload
    assert user.verified
    assert_logged_in(user)
  end

  def test_forgot_password_allows_change_password_after_mailing_key
    user = users(:lars)
    post url_for(:controller => 'user', :action => 'forgot_password'), :user => {:email => user.email}
    assert_equal 1, Mail::TestMailer.deliveries.size
    mail = Mail::TestMailer.deliveries[0]
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal 2, mail.body.parts.size
    body = mail.html_part.body.decoded
    assert body =~ /user\[id\]=(.+?)&amp;key=(.+?)"/,
           "Unable to find user id and key in the message: #{body.inspect}"
    id = $1
    key = $2
    post url_for(:controller => 'user', :action => 'change_password'),
         :user => {:password => 'newpassword',
                   :password_confirmation => 'newpassword',
                   :id => id},
         :key => key
    user.reload
    assert_logged_in user
    assert_equal user, User.authenticate(user.login, 'newpassword')
  end


  private

  def assert_logged_in(user)
    assert_equal user.id, request.session[:user_id]
  end

  def assert_not_logged_in
    assert_nil request.session[:user_id]
    assert_nil assigns(:current_user)
  end

  def assert_redirected_to_login
    assert_response :redirect
    assert_equal controller.url_for(:action => 'login'), response.redirect_url
  end

end
