# frozen_string_literal: true

require 'test_helper'

class IntegrationTest < ActionDispatch::IntegrationTest
  teardown { get '/logout' }

  def login(login = :admin)
    user = users(login)
    post '/login/password', params: { user: { login: user.login, password: :atest } }
    user
  end

  def assert_logged_in
    cookies[COOKIE_NAME]
  end
end
