require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/app/views/'
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

MiniTest::Reporters.use!

TEST_TIME = Time.local(2013, 10, 17, 18, 46, 0) # Week 42, thursday

class ActiveSupport::TestCase
  fixtures :all

  setup { Timecop.freeze(TEST_TIME) }
  teardown { Timecop.return }

  def login(login = :admin)
    u = users(login)
    request.session[:user_id] = u.id
    Thread.current[:user] = u
  end

  def logout
    request.session.delete(:user_id)
    Thread.current[:user] = nil
  end

  def assert_no_errors(symbol)
    v = assigns(symbol)
    assert v, "Assignment #{symbol} not found in the controller."
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

require_relative 'capybara_setup'
require 'ish'

VCR.configure do |config|
  config.cassette_library_dir = "#{Rails.root}/test/vcr_cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
end
