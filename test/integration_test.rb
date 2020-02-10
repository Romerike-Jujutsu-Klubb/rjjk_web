# frozen_string_literal: true

require 'test_helper'

class IntegrationTest < ActionDispatch::IntegrationTest
  teardown do
    get logout_path reply: 'done'
    assert_equal 'done', response.body
  end

  def login(login = :uwe)
    user = users(login)
    post login_password_path user: { login: user.login || user.email, password: :atest }
    user
  end

  def assert_logged_in(user = :uwe)
    user = users(user).reload if user.is_a?(Symbol)
    assert_equal user.security_token, session['user_id']
  end

  def assert_not_logged_in
    assert cookies[COOKIE_NAME].blank?
    assert_nil session['user_id']
  end
end
