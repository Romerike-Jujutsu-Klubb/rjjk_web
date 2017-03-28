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

  Capybara.default_driver = :poltergeist # :selenium or :poltergeist
  Capybara::Screenshot.add_driver_path = true
  Capybara::Screenshot.window_size = [1024, 768]
  Capybara::Screenshot.enabled = RUBY_ENGINE == 'ruby' && ENV['TRAVIS'].blank?
  # Capybara::Screenshot::Diff.enabled = false
  Capybara::Screenshot.stability_time_limit = 0.5
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
    assert has_css? '#gallery_img[src="/images/inline/298486374/412.picture%20two"]'
  end
end
