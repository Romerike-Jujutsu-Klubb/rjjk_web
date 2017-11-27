# frozen_string_literal: true

require 'test_helper'

class ActionController::TestCase
  teardown { clear_user }

  def login(login = :admin)
    self.current_user = users(login)
  end

  def assert_logged_in(user = :admin)
    user = users(user) if user.is_a? Symbol
    assert_equal user.id, session[:user_id]
  end

  def assert_not_logged_in
    assert_nil session[:user_id]
    assert_nil assigns(:current_user)
  end

  def assert_no_errors(symbol)
    v = assigns(symbol)
    assert v, "Assignment #{symbol} not found in the controller."
    assert_equal [], v.errors.full_messages
  end
end
