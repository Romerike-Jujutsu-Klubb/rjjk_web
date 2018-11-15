# frozen_string_literal: true

module SystemTestHelper
  extend ActiveSupport::Concern

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

  included do
    setup { Timecop.travel TEST_TIME }
    teardown do
      visit logout_path
      find('.alert button.close').click
      open_menu
      find('a', text: 'Logg inn')
      # FIXME(uwe): Is this necessary?
      Capybara.reset_sessions!
      # clear_cookies
    end
  end

  # def clear_cookies
  #   browser = Capybara.current_session.driver.browser
  #   if browser.respond_to?(:clear_cookies)
  #     # Rack::MockSession
  #     browser.clear_cookies
  #   elsif browser.respond_to?(:manage) && browser.manage.respond_to?(:delete_all_cookies)
  #     # Selenium::WebDriver
  #     browser.manage.delete_all_cookies
  #   else
  #     raise "Don't know how to clear cookies. Weird driver?"
  #   end
  # end

  def visit_with_login(path, redirected_path: path, user: :admin)
    visit path
    assert_current_path '/login'
    click_on 'logge på med passord'
    assert_current_path login_password_path
    fill_login_form(user)
    assert_current_path redirected_path
  end

  def login_and_visit(path, user = :admin, redirected_path: path)
    login(user)
    assert_current_path '/'
    visit path
    assert_current_path redirected_path
  end

  def login(user = :admin)
    visit '/login/password'
    fill_login_form user
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

  def open_menu
    find('#navBtn').click
  end

  def click_menu(menu_item)
    open_menu
    click_link menu_item
  end
end
