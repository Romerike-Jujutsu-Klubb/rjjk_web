# frozen_string_literal: true

require 'test_helper'

class ActionController::TestCase
  teardown do
    clear_user
    clear_session
    clear_cookie
  end

  def login(login = :admin)
    Thread.current[:user] = users(login)
  end

  def clear_cookie
    cookies.delete(COOKIE_NAME)
    cookies.delete(:email)
    ActionDispatch::Request.new(Rails.application.env_config).cookie_jar
        .delete(COOKIE_NAME, COOKIE_SCOPE)
    ActionDispatch::Request.new(Rails.application.env_config).cookie_jar.delete(:email)
  end

  def assert_no_errors(symbol)
    v = assigns(symbol)
    assert v, "Assignment #{symbol} not found in the controller."
    assert_equal [], v.errors.full_messages
  end
end
