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
    browser_options.args << '--force-color-profile=srgb'
    browser_options.args << '--force-device-scale-factor=1'
    browser_options.args << '--headless'
    browser_options.args << '--lang=nb'
    browser_options.args << '--use-fake-ui-for-media-stream'
    browser_options.args << "--window-size=#{WINDOW_SIZE.join('x')}"
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
  end

  Capybara.default_max_wait_time = 10 * TEST_RUNNERS
  Capybara::Screenshot.add_driver_path = true
  Capybara::Screenshot.window_size = WINDOW_SIZE
  Capybara::Screenshot.enabled = ENV['CI'].blank?
  Capybara::Screenshot.hide_caret = true
  Capybara::Screenshot::Diff.area_size_limit = 6
  Capybara::Screenshot::Diff.color_distance_limit = 12

  # FIXME(uwe): Consider rack driver as default for speed
  driven_by :chrome
  Capybara.server = :puma, { Silent: true }

  setup do
    Timecop.travel TEST_TIME

    Rails.application.routes.default_url_options =
        { host: Capybara.current_session.server.host, port: Capybara.current_session.server.port }

    screenshot_section class_name.underscore.sub(/(_feature|_system)?_test$/, '')
    screenshot_group name[5..]
  end

  teardown do
    execute_script 'new AbortController().abort()'
    Capybara.reset_session!
    unless passed?
      log = page.driver.browser.manage.logs.get(:browser).map(&:message).join("\n")
      puts "Browser log: #{log}" if log.present?
    end
  end
end

Capybara::Node::Element.class_eval do
  def click_at
    driver.browser.action.move_to(native).click.perform
  end
end
