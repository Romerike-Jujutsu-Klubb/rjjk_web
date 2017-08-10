# frozen_string_literal: true

require 'test_helper'
require 'minitest/rails/capybara'
require 'capybara/poltergeist'
require 'capybara/screenshot/diff'

# Transactional fixtures do not work with Selenium tests, because Capybara
# uses a separate server thread, which the transactions would be hidden
# from. We hence use DatabaseCleaner to truncate our test database.
# DatabaseCleaner.strategy = :truncation

class ActionDispatch::IntegrationTest
  include Capybara::DSL

  WINDOW_SIZE = [1024, 768].freeze

  Capybara::Screenshot.add_driver_path = true
  Capybara::Screenshot.window_size = WINDOW_SIZE
  Capybara::Screenshot.enabled = RUBY_ENGINE == 'ruby' && ENV['TRAVIS'].blank?
  # Capybara::Screenshot::Diff.enabled = false
  Capybara::Screenshot.stability_time_limit = 0.5
  Capybara.register_driver :chrome do |app|
    caps = Selenium::WebDriver::Remote::Capabilities.chrome(
        'chromeOptions' => { 'args' => %W[headless window-size=#{WINDOW_SIZE.join('x')}] }
    )
    Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: caps)
  end
  Capybara.default_driver = :chrome # :selenium, :chrome, or :poltergeist
  if Capybara.default_driver == :chrome
    Capybara::Screenshot::Diff.color_distance_limit = 65
    Capybara::Screenshot.blur_active_element = true
  end
  Capybara.default_max_wait_time = 30

  self.use_transactional_tests = false

  setup { Timecop.travel TEST_TIME }

  teardown do
    DatabaseCleaner.clean # Truncate the database
    Capybara.reset_sessions! # Forget the (simulated) browser state
  end

  def visit_with_login(path, redirected_path: path, user: :admin)
    visit path
    if current_path == '/login'
      click_on 'logge på med passord'
      assert_current_path login_password_path
      fill_login_form(user)
    end
    assert_current_path redirected_path
  end

  def login_and_visit(path, user = :admin)
    visit '/login/password'
    fill_login_form user
    assert_current_path '/'
    visit path
  end

  def fill_login_form(user)
    fill_in 'user_login', with: user
    fill_in 'user_password', with: 'atest'
    click_button 'Logg inn'
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop do
        active = page.evaluate_script('jQuery.active')
        break if active.zero?
        sleep 0.01
      end
    end
  end

  def assert_gallery_image_is_loaded
    return unless Capybara::Screenshot.enabled
    assert has_css? '#gallery_img[src="/images/inline/298486374/412.picture%20two"]'
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
