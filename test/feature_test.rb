# frozen_string_literal: true

require 'test_helper'
require 'minitest/rails/capybara'
require 'capybara/screenshot/diff'
require 'system_test_helper'

# Transactional fixtures do not work with Selenium tests, because Capybara
# uses a separate server thread, which the transactions would be hidden
# from. We hence use DatabaseCleaner to truncate our test database.
# DatabaseCleaner.strategy = :truncation

class FeatureTest < ActionDispatch::IntegrationTest
  include Capybara::Screenshot::Diff
  include SystemTestHelper

  WINDOW_SIZE = [1024, 768].freeze

  Capybara::Screenshot.add_driver_path = true
  Capybara::Screenshot.window_size = WINDOW_SIZE
  Capybara::Screenshot.enabled = ENV['TRAVIS'].blank?
  Capybara::Screenshot.stability_time_limit = 0.5

  Capybara.register_driver :chrome do |app|
    # Capybara::Selenium::Driver.load_selenium
    browser_options = ::Selenium::WebDriver::Chrome::Options.new
    browser_options.args << '--headless'
    browser_options.args << '--disable-gpu' if Gem.win_platform?
    browser_options.args << "--window-size=#{WINDOW_SIZE.join('x')}"
    browser_options.args << '--force-device-scale-factor=1'
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
  end

  Capybara.default_driver = :chrome # :selenium, :chrome
  if Capybara.default_driver == :chrome
    Capybara::Screenshot::Diff.color_distance_limit = 14.5
    Capybara::Screenshot::Diff.area_size_limit = 18
  end
  Capybara.default_max_wait_time = 30

  self.use_transactional_tests = false

  setup { Timecop.travel TEST_TIME }

  teardown do
    Capybara.reset_sessions! # Forget the (simulated) browser state
    DatabaseCleaner.clean # Truncate the database
  end
end

if Capybara.default_driver == :chrome
  module ClickScroller
    def click
      script = "document.evaluate('#{path}', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoViewIfNeeded()" # rubocop: disable Metrics/LineLength
      driver.execute_script script
      super
    end
  end
  Capybara::Selenium::Node.prepend ClickScroller
end
