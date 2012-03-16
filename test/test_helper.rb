ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

if ENV["RM_INFO"] || ENV["TEAMCITY_VERSION"]
  require 'minitest/reporters'
  MiniTest::Unit.runner = MiniTest::SuiteRunner.new
  MiniTest::Unit.runner.reporters << MiniTest::Reporters::RubyMineReporter.new
end

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

class Mail::TestMailer
  cattr_accessor :inject_one_error
  self.inject_one_error = false

  def deliver_with_error!(mail)
    if inject_one_error
      self.class.inject_one_error = false
      raise "Failed to send email" if ActionMailer::Base.raise_delivery_errors
    end
    deliver_without_error! mail
  end
  alias_method_chain :deliver!, :error
end
