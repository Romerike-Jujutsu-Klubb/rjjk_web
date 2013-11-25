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

require 'capybara/rails'

# Transactional fixtures do not work with Selenium tests, because Capybara
# uses a separate server thread, which the transactions would be hidden
# from. We hence use DatabaseCleaner to truncate our test database.
DatabaseCleaner.strategy = :truncation

class ActionDispatch::IntegrationTest
  include Capybara::DSL

  Capybara.default_driver = :selenium

  self.use_transactional_fixtures = false

  setup do
    Capybara.current_session.driver.browser.manage.window.resize_to(1280, 1024)
    Timecop.travel
  end

  teardown do
    DatabaseCleaner.clean       # Truncate the database
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end
end
