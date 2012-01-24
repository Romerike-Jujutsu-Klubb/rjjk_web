ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def login(login)
    @request.session[:user_id] = users(login).id
  end

  def assert_no_errors(symbol)
    v = assigns(symbol)
    assert v
    assert_equal [], v.errors.full_messages
  end

end

ActionMailer::Base.class_eval {
  @@inject_one_error = false
  cattr_accessor :inject_one_error

  private

  def perform_delivery_test(mail)
    if inject_one_error
      ActionMailer::Base::inject_one_error = false
      raise "Failed to send email" if raise_delivery_errors
    else
      deliveries << mail
    end
  end
}
