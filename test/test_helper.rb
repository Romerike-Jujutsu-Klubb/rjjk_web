ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

if ENV['RM_INFO'] || ENV['TEAMCITY_VERSION']
  require 'minitest/reporters'
  MiniTest::Reporters.use!
end

class ActiveSupport::TestCase
  fixtures :all

  def login(login)
    u = users(login)
    @request.session[:user_id] = u.id
    Thread.current[:user] = u
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
      raise 'Failed to send email' if ActionMailer::Base.raise_delivery_errors
    end
    deliver_without_error! mail
  end
  alias_method_chain :deliver!, :error
end

require 'capybara_setup'
