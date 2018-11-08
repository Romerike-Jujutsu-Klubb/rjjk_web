# frozen_string_literal: true

require 'integration_test'

class UserSystemTest < ActionDispatch::IntegrationTest
  def test_signup_and_verify
    post url_for(controller: :login, action: :signup), params: {
      user: { login: 'newuser',
              password: 'password', password_confirmation: 'password',
              email: 'newemail@example.com' },
    }

    assert_not_logged_in
    assert_redirected_to_login
    UserMessageSenderJob.perform_now
    assert_equal 1, Mail::TestMailer.deliveries.size

    mail = Mail::TestMailer.deliveries[0]
    assert_equal ['uwe@kubosch.no'], mail.to # Test email
    assert_equal ['"newemail@example.com" <uwe@kubosch.no>'], mail[:to].address_list.addresses.map(&:to_s)
    body = mail.body.decoded
    assert_match(/Brukernavn:\s+\w+\r\n/, body)
    assert_match(/Passord\s*:\s+\w+\r\n/, body)
    assert(body =~ /key=(.*?)"/)
    key = Regexp.last_match(1)

    assert user = User.find_by(login: 'newuser')
    Timecop.freeze(Time.current + User.token_lifetime(:login) + 1) do
      get url_for(controller: :login, action: :welcome), params: { key: key }
      assert_redirected_to_login
      user.reload
      assert_not user.verified
      assert_not_logged_in
    end

    get url_for(controller: :login, action: :welcome), params: { key: 'boguskey' }
    assert_redirected_to_login
    assert_not_logged_in
    user.reload
    assert_not user.verified

    get url_for(controller: :login, action: :welcome), params: { key: key }
    assert_response :success
    user.reload
    assert user.verified
    assert_logged_in(user)
  end

  def test_forgot_password_allows_change_password_after_mailing_key
    user = users(:lars)

    post url_for(controller: :login, action: :forgot_password), params: { user: { email: user.email } }

    UserMessageSenderJob.perform_now
    assert_equal 1, Mail::TestMailer.deliveries.size
    mail = Mail::TestMailer.deliveries[0]
    assert_equal ['"lars@example.com" <uwe@kubosch.no>'], mail[:to].address_list.addresses.map(&:to_s)
    html_part, plain_part = mail.parts_by_type
    assert plain_part&.body&.decoded
    assert html_part&.body&.decoded
    assert(html_part&.body&.decoded =~ /key=(.*?)"/)
    key = Regexp.last_match(1)

    post url_for(controller: :login, action: :change_password), params: {
      user: { password: 'newpassword',
              password_confirmation: 'newpassword' },
      key: key,
    }

    follow_redirect!
    assert_logged_in user
    assert_equal user, User.authenticate(user.login, 'newpassword')
  end

  private

  def assert_logged_in(user)
    assert_select 'h1', { text: user.name }, "This page must contain a login header: #{response.body}"
  end

  def assert_not_logged_in
    assert_select 'h1', false, 'This page must contain no login header'
  end

  def assert_redirected_to_login
    assert_response :redirect
    assert_redirected_to login_path
  end
end
