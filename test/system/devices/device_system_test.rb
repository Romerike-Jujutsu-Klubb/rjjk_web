# frozen_string_literal: true

require 'application_system_test_case'
require_relative 'new_front_page_system_tests'

module DeviceSystemTest
  extend ActiveSupport::Concern
  include NewFrontPageSystemTests

  USER_AGENT = <<~UA
    Mozilla/5.0 (Linux; Android 6.0.1; Nexus 7 Build/MOB30X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.119 Safari/537.36
  UA

  included do
    cattr_accessor :logo_area
    cattr_accessor :menu_logo_area
    cattr_accessor :public_menu_btn_area
    cattr_accessor :public_menu_logo_area
    setup do
      screenshot_section :front
      Capybara::Screenshot.window_size = nil
      @orig_color_distance_limit = Capybara::Screenshot::Diff.color_distance_limit
      Capybara::Screenshot::Diff.color_distance_limit = 61.3 # Small variations in rendering...
    end
    teardown do
      Capybara::Screenshot::Diff.color_distance_limit = @orig_color_distance_limit
      Capybara::Screenshot.window_size = ApplicationSystemTestCase::WINDOW_SIZE
    end
  end

  class_methods do
    def driver_name
      name.chomp('Test').camelize
    end

    def use_device(device_name: nil, device_metrics: nil, menu_logo_area:, logo_area:,
        public_menu_btn_area:, public_menu_logo_area:)
      self.menu_logo_area = menu_logo_area.freeze
      self.logo_area = logo_area.freeze
      self.public_menu_btn_area = public_menu_btn_area.freeze
      self.public_menu_logo_area = public_menu_logo_area.freeze
      Capybara.register_driver driver_name do |app|
        browser_options = ::Selenium::WebDriver::Chrome::Options.new
        browser_options.headless!
        browser_options.args << '--force-color-profile=srgb'
        browser_options.args << '--lang=nb'
        if device_name
          browser_options.add_emulation(device_name: device_name)
        else
          browser_options.add_emulation(device_metrics: device_metrics, user_agent: USER_AGENT)
        end
        Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
      end
      driven_by driver_name
    end
  end

  def window_width
    @window_width ||= (evaluate_script(<<~JS) * device_pixel_ratio).ceil
      window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth
    JS
  end

  def window_height
    @window_height ||= (evaluate_script(<<~JS) * device_pixel_ratio).ceil
      window.innerHeight|| document.documentElement.clientHeight|| document.body.clientHeight
    JS
  end

  def device_pixel_ratio
    @device_pixel_ratio ||= evaluate_script('window.devicePixelRatio')
  end

  def scroll_bar_area
    [window_width - 19, 0, window_width - 1, window_height - 1]
  end

  def progress_bar_area
    [0, window_height - 8, window_width - 1, window_height - 1]
  end

  def test_parallax_front_page
    visit front_parallax_path
    screenshot :index, skip_area: scroll_bar_area
    landscape { screenshot :index_landscape, skip_area: scroll_bar_area }

    scroll_to find('#slide-event')
    screenshot 'slide-event', skip_area: scroll_bar_area
    landscape do
      scroll_to find('#slide-event')
      screenshot 'slide-event_landscape', skip_area: scroll_bar_area
    end

    (1..2).each do |i|
      scroll_to find("#slide#{i}")
      screenshot "slide#{i}", skip_area: scroll_bar_area
      landscape do
        scroll_to find("#slide#{i}")
        screenshot "slide#{i}_landscape", skip_area: scroll_bar_area
      end
    end

    scroll_to find('footer')
    screenshot :footer, skip_area: scroll_bar_area
    landscape do
      scroll_to find('footer')
      screenshot :footer_landscape, skip_area: scroll_bar_area
    end
  end

  private

  def landscape
    original_width = window_width
    original_height = window_height
    @window_width = original_height
    @window_height = original_width
    page.driver.browser.execute_cdp('Emulation.setDeviceMetricsOverride',
        width: @window_width,
        height: @window_height,
        deviceScaleFactor: 1,
        mobile: true)
    yield
    @window_width = original_width
    @window_height = original_height
    page.driver.browser.execute_cdp('Emulation.setDeviceMetricsOverride',
        width: original_width,
        height: original_height,
        deviceScaleFactor: 1,
        mobile: true)
  end

  def assert_offset(selector, side, expected_offset)
    start = Time.current
    loop do
      offset = evaluate_script("$('#{selector}').offset().left")
      if side == :right
        window_width = evaluate_script('Math.max(document.documentElement.clientWidth, window.width || 0)')
        width = evaluate_script("$('#{selector}').outerWidth()")
        offset = window_width - offset - width
      end
      break if offset == expected_offset
      if Time.current - start > Capybara.default_max_wait_time
        raise "Expected #{side} offset of #{selector.inspect} to be #{expected_offset}, but was #{offset}"
      end

      sleep 0.01
    end
  end
end
