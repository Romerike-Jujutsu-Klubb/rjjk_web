# frozen_string_literal: true

require 'test_helper'

class ActionDispatch::IntegrationTest
  teardown do
    clear_user
    clear_cookie
  end

  def login(login = :admin)
    store_login_cookie(login)
    users(login)
  end

  def store_login_cookie(login)
    cookies[COOKIE_NAME] = encrypted_cookie_value(login)
  end

  def clear_cookie
    cookies.delete(COOKIE_NAME)
    cookies.delete(:email)
    cookies[COOKIE_NAME] = nil
    cookies[:email] = nil
    ActionDispatch::Request.new(Rails.application.env_config).cookie_jar
        .delete(COOKIE_NAME, COOKIE_SCOPE)
    ActionDispatch::Request.new(Rails.application.env_config).cookie_jar.delete(:email)
  end

  def encrypted_cookie_value(login)
    encrypted_cookies = ActionDispatch::Request.new(Rails.application.env_config).cookie_jar
    encrypted_cookies.encrypted[COOKIE_NAME] = ActiveRecord::FixtureSet.identify(login)
    encrypted_cookies[COOKIE_NAME]
  end
end
