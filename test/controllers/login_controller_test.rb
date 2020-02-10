# frozen_string_literal: true

require 'integration_test'

class LoginControllerTest < IntegrationTest
  include ActionMailer::TestCase::ClearTestDeliveries
  def test_login_valid_login_redirects_as_specified
    get root_path # build session
    session[:detours] = [{ controller: :welcome, action: :index }]
    post login_password_path, params: { user: { login: 'lars', password: 'atest' } }
    assert_logged_in users(:lars)
    assert_response :redirect
    assert_redirected_to controller: :welcome, action: :index
  end

  def test_login_with_remember_me
    post login_password_path, params: { user: { login: 'lars', password: 'atest' }, remember_me: '1' }

    assert_logged_in users(:lars)
    assert_response :redirect
    assert_redirected_to controller: :welcome, action: :index
    assert cookies[COOKIE_NAME]
    assert_equal false, users(:lars).token_expired?
    assert_not_equal 'random_token_string', users(:lars).security_token
  end

  def test_autologin_with_token
    login(:lars)
    session['user_id'] = ''

    get login_welcome_path
    assert_response :ok
    assert_logged_in :lars
  end

  def test_login_valid_login_shows_welcome_as_default
    post login_password_path user: { login: 'lars', password: 'atest' }
    assert_logged_in users(:lars)
    assert_response :redirect
    assert_equal @controller.url_for(controller: :welcome, action: :index, only_path: false),
        @response.redirect_url
  end

  def test_login_wrong_password
    post login_password_path, params: { user: { login: 'lars', password: 'wrong password' } }
    assert_not_logged_in
    assert_contains 'Innlogging feilet.', flash.notice
  end

  def test_login_wrong_login
    post login_password_path, params: { user: { login: 'wrong login', password: 'atest' } }
    assert_not_logged_in
    assert_contains 'Innlogging feilet.', flash.notice
  end

  def test_login_deleted_user_cant_login
    post login_password_path, params: { user: { login: 'deleted_tesla', password: 'atest' } }
    assert_not_logged_in
    assert_contains 'Innlogging feilet.', flash.notice
  end

  def test_signup
    post_signup login: 'newuser',
                password: 'password', password_confirmation: 'password',
                email: 'newemail@example.com'
    assert_not_logged_in
    assert_redirected_to_login
    UserMessageSenderJob.perform_now
    assert_equal 1, Mail::TestMailer.deliveries.size

    mail = Mail::TestMailer.deliveries[0]
    assert_equal ['"newemail@example.com" <uwe@kubosch.no>'], mail[:to].address_list.addresses.map(&:to_s)
    body = mail.body.decoded
    assert_match(/Brukernavn:\s+\w+\r\n/, body)
    assert_match(/Passord\s*:\s+\w+\r\n/, body)
    user = User.find_by(email: 'newemail@example.com')
    assert_match(/key=#{user.security_token}/, body)
    assert_not user.verified
  end

  def test_signup_cannot_set_arbitrary_attributes
    post_signup login: 'newuser',
                password: 'password', password_confirmation: 'password',
                email: 'skunk@example.com',
                verified: '1',
                role: 'superadmin'
    user = User.find_by(email: 'skunk@example.com')
    assert_not user.verified
    assert_nil user.role
  end

  def test_signup_validates_password_min_length
    post_signup login: 'tesla_rhea', password: 'bad', password_confirmation: 'bad',
                email: 'someone@example.com'
    assert_password_validation_fails
  end

  def test_signup_mismatched_passwords
    post login_signup_path, params: { user: {
      login: 'newtesla', email: 'newtesla@example.com', password: 'newpassword', password_confirmation: 'wrong'
    } }
    assert_response :success
  end

  def test_signup_bad_login
    post_signup login: 'yo', email: 'yo@example.com', password: 'newpassword', password_confirmation: 'newpassword'
    assert_response :success
  end

  def test_welcome
    user = users(:unverified_user)
    get login_welcome_path, params: { user: { id: user.id }, key: user.security_token }
    user.reload
    assert user.verified
    assert_logged_in(user)
  end

  def test_welcome_fails_if_expired_token
    user = users(:unverified_user)
    Timecop.freeze(Time.current + User.token_lifetime) do # now past verification deadline
      get login_welcome_path, params: { user: { id: user.id }, key: user.security_token }
      user.reload
      assert_not user.verified
      assert_not_logged_in
    end
  end

  def test_welcome_fails_if_bad_token
    user = users(:unverified_user)
    get login_welcome_path, params: { user: { id: user.id }, key: 'boguskey' }
    assert_redirected_to_login
    user.reload
    assert_not user.verified
    assert_not_logged_in
  end

  def test_send_login_link
    user = users(:unverified_user)
    user.update! security_token: nil
    sms_key = nil
    stub_request(:post, 'https://example.com/sms/send/mt')
        .with { |request| sms_key = request.body[/(?<=text=http%3A%2F%2Fwww.example.com%2F%3Fkey%3D).*/] }
        .to_return(status: 200, body: '', headers: {})

    post send_login_link_path, params: { user: { identity: user.phone } }

    assert_redirected_to login_link_message_sent_path(identity: user.phone)
    assert_equal sms_key, user.reload.security_token

    follow_redirect!
    assert_equal sms_key, user.reload.security_token

    get root_path(key: sms_key)
    assert_response :success

    user.reload
    assert user.verified
    assert_logged_in(:unverified_user)
  end

  def test_change_password
    user = login(:lars)
    post change_password_path, params: { user: {
      password: 'changed_password', password_onfirmation: 'changed_password'
    } }
    UserMessageSenderJob.perform_now
    assert_equal 1, Mail::TestMailer.deliveries.size
    mail = Mail::TestMailer.deliveries[0]
    assert_equal ['"lars@example.com" <uwe@kubosch.no>'], mail[:to].address_list.addresses.map(&:to_s)
    assert_equal user, User.authenticate(user.login, 'changed_password')
  end

  def test_change_password__confirms_password
    login(:lars)
    post change_password_path, params: { user: { password: 'bad', password_confirmation: 'bad' } }
    assert_response :success
    UserMessageSenderJob.perform_now
    assert_equal 1, Mail::TestMailer.deliveries.size
  end

  def test_forgot_password__when_logged_in_redirects_to_change_password
    user = login(:lars)
    post forgot_password_path, params: { user: { email: user.email } }
    UserMessageSenderJob.perform_now
    assert_equal 0, Mail::TestMailer.deliveries.size
    assert_response :redirect
    assert_equal @controller.url_for(action: 'change_password'), @response.redirect_url
  end

  def test_forgot_password__requires_valid_email_address
    post forgot_password_path, params: { user: { email: '' } }
    UserMessageSenderJob.perform_now
    assert_equal 0, Mail::TestMailer.deliveries.size
    assert_match(/Skriv inn en gyldig e-postadresse./, @response.body)
  end

  def test_forgot_password__ignores_unknown_email_address
    post forgot_password_path, params: { user: { email: 'unknown_email@example.com' } }
    UserMessageSenderJob.perform_now
    assert_equal 0, Mail::TestMailer.deliveries.size
  end

  def test_invalid_login
    post login_password_path, params: { user: { login: 'lars', password: 'not_correct' } }
    assert_not_logged_in
    assert_response :success
  end

  def test_logout
    login(:lars)
    cookies[:user_id_test] = '1'
    assert_equal(%w[_rjjk_web_test_session user_id_test], cookies.to_hash.keys)
    get logout_path
    assert_not_logged_in
  end

  private

  def assert_redirected_to_login
    assert_redirected_to login_url
  end

  def post_signup(user_params)
    post login_signup_path, params: { user: user_params }
  end

  def assert_password_validation_fails
    assert_response :success
    UserMessageSenderJob.perform_now
    assert_equal 0, Mail::TestMailer.deliveries.size
  end

  def assert_contains(target, container)
    assert_not container.nil?, %( Failed to find "#{target}" in nil String )
    assert container.include?(target), "#{container.inspect} does not contain #{target.inspect}"
  end
end
