# frozen_string_literal: true

require 'application_system_test_case'

class MediumDevicesTest < ApplicationSystemTestCase
  MEDIUM_WINDOW_SIZE = [640, 480].freeze
  FRONT_PAGE_PROGRESS_BAR_AREA = [0, 477, 292, 479].freeze
  SUBNAV_OFFSET = ENV['TRAVIS'] ? -253 : -268 # FIXME(uwe): Why the difference?
  USER_AGENT = <<~UA
    Mozilla/5.0 (Linux; Android 6.0.1; Nexus 7 Build/MOB30X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.119 Safari/537.36
  UA

  Capybara.register_driver :chrome_medium do |app|
    browser_options = ::Selenium::WebDriver::Chrome::Options.new
    browser_options.args << '--force-color-profile=srgb'
    browser_options.args << '--force-device-scale-factor=1' # FIXME(uwe): Remove with Chrome 74
    browser_options.args << "--window-size=#{MEDIUM_WINDOW_SIZE.join('x')}" # FIXME(uwe): Remove with Chrome 74
    browser_options.add_emulation(
        # FIXME(uwe): Re-enable with Chrome 74
        # device_metrics: { width: MEDIUM_WINDOW_SIZE[0], height: MEDIUM_WINDOW_SIZE[1], pixelRatio: 1, touch: true },
        # EMXIF
        user_agent: USER_AGENT
    )
    browser_options.headless!
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
  end

  driven_by :chrome_medium

  setup do
    screenshot_section :medium_devices
    Capybara::Screenshot.window_size = nil
    Capybara.current_session.current_window.resize_to(*MEDIUM_WINDOW_SIZE) # FIXME(uwe): Remove with Chrome 74
  end

  teardown do
    Capybara::Screenshot.window_size = ApplicationSystemTestCase::WINDOW_SIZE
  end

  test 'member front_page' do
    screenshot_group :front_page
    login_and_visit root_path
    assert_selector 'h4', text: 'Neste trening'
    assert_offset '.subnav', :left, SUBNAV_OFFSET
    assert_offset '.main_right', :right, SUBNAV_OFFSET
    screenshot :index

    find('.fa-navicon').click # Display menu
    assert_offset '.subnav', :left, 0
    assert_selector 'li a', text: 'My first article'
    find('h1', text: 'Instruksjon').hover
    assert_css '#menuShadow'
    screenshot :menu
    find('.fa-calendar').click_at # Hide menu
    assert_offset '.subnav', :left, SUBNAV_OFFSET
    assert_no_css '#menuShadow'
    screenshot :menu_closed

    find('#calendarBtn').click # Display calendar sidebar
    assert_offset '.main_right', :right, 0
    assert_css '#sidebarShadow'
    screenshot :calendar
    find('#sidebarShadow').click # Hide calendar sidebar
    assert_offset '.main_right', :right, SUBNAV_OFFSET
    assert_no_css '#sidebarShadow'
    screenshot :calendar_closed
  end

  test 'new front_page' do
    screenshot_group :new_front_page
    visit front_page_path
    assert_css('#headermenuholder > i')
    screenshot :index, area_size_limit: 533, skip_area: FRONT_PAGE_PROGRESS_BAR_AREA
    find('#headermenuholder > i').click
    article_menu_link = find('.menubutton', text: 'My first article')
    article_menu_link.hover # FIXME(uwe): Remove with Chrome 74 + mobile emulation
    screenshot :menu
    begin
      article_menu_link.click
    rescue
      tries ||= 1
      raise "article menu click failed (#{tries}): #{$ERROR_INFO}" if tries >= 6

      sleep 0.001
      tries += 1
      retry
    end
    assert_css 'h1', text: 'My first article'
    screenshot :article
  end

  test 'new front page scroll' do
    screenshot_group :new_front_page_scroll
    visit front_page_path
    assert_css('#headermenuholder > i')
    assert_css('.fa-chevron-down')
    screenshot :index, area_size_limit: 533, skip_area: FRONT_PAGE_PROGRESS_BAR_AREA
    find('.fa-chevron-down').click
    article_link = find('#footer .menu-item a', text: 'MY FIRST ARTICLE')
    screenshot(:scrolled) || (sleep(0.5) if ENV['TRAVIS'])
    article_link.click
    assert_css('h1', text: 'My first article')
    screenshot :article
  end

  private

  def assert_offset(selector, side, expected_offset)
    start = Time.current
    loop do
      offset = evaluate_script("$('#{selector}').offset().left")
      if side == :right
        window_width = evaluate_script('Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')
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
