# frozen_string_literal: true

require 'test_helper'
require 'system_test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include Capybara::Screenshot::Diff
  include SystemTestHelper

  WINDOW_SIZE = [1024, 768].freeze

  # options explained https://peter.sh/experiments/chromium-command-line-switches/
  # no-sandbox
  #   because the user namespace is not enabled in the container by default
  # headless
  #   run w/o actually launching gui
  # disable-gpu
  #   Disables graphics processing unit(GPU) hardware acceleration
  # window-size
  #   sets default window size in case the smaller default size is not enough
  #   we do not want max either, so this is a good compromise
  # use-fake-ui-for-media-stream
  #   Avoid dialogs to grant permission to use the camera

  Capybara.register_driver :chrome do |app|
    browser_options = ::Selenium::WebDriver::Chrome::Options.new
    browser_options.args << '--disable-gpu' if Gem.win_platform?
    browser_options.args << '--force-device-scale-factor=1'
    browser_options.args << '--headless'
    browser_options.args << '--use-fake-ui-for-media-stream'
    browser_options.args << "--window-size=#{WINDOW_SIZE.join('x')}"
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
  end

  Capybara.default_max_wait_time = 10
  Capybara::Screenshot.add_driver_path = true
  Capybara::Screenshot.window_size = WINDOW_SIZE
  Capybara::Screenshot.enabled = ENV['TRAVIS'].blank?
  Capybara::Screenshot.hide_caret = true
  Capybara::Screenshot.stability_time_limit = 0.1

  driven_by :chrome
  Capybara.server = :puma, { Silent: true }

  setup do
    Timecop.travel TEST_TIME

    Rails.application.routes.default_url_options =
        { host: Capybara.current_session.server.host, port: Capybara.current_session.server.port }
  end

  teardown do
    visit logout_path
    open_menu
    find('a', text: 'Logg inn')
    Capybara.reset_sessions!
    clear_cookies
  end
end
