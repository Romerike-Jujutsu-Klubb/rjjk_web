# frozen_string_literal: true

require 'application_system_test_case'

class MediumDevicesTest < ApplicationSystemTestCase
  MEDIUM_WINDOW_SIZE = [640, 480].freeze
  FRONT_PAGE_PROGRESS_BAR_AREA = [0, 477, 292, 479].freeze
  SUBNAV_OFFSET = -268
  USER_AGENT = <<~UA
    Mozilla/5.0 (Linux; Android 6.0.1; Nexus 7 Build/MOB30X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.119 Safari/537.36
  UA

  Capybara.register_driver :chrome_medium do |app|
    browser_options = ::Selenium::WebDriver::Chrome::Options.new
    browser_options.args << '--force-color-profile=srgb'
    browser_options.add_emulation(
        device_metrics: { width: MEDIUM_WINDOW_SIZE[0], height: MEDIUM_WINDOW_SIZE[1], pixelRatio: 1, touch: true },
        user_agent: USER_AGENT
      )
    browser_options.headless!
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
  end

  driven_by :chrome_medium

  setup do
    screenshot_section :medium_devices
    Capybara::Screenshot.window_size = nil
  end

  teardown { Capybara::Screenshot.window_size = ApplicationSystemTestCase::WINDOW_SIZE }

  test 'member front_page' do
    screenshot_group :front_page
    login_and_visit root_path
    assert_selector 'h4', text: 'Neste trening'
    assert_offset '.subnav', :left, SUBNAV_OFFSET
    assert_offset '.main_right', :right, SUBNAV_OFFSET
    screenshot :index

    find('.fa-bars').click # Display menu
    assert_offset '.subnav', :left, 0
    assert_selector 'li a', text: 'My first article'
    find('h1', text: 'Instruksjon').hover
    assert_css '#menuShadow'
    screenshot :menu
    find('.fa-calendar-alt').click_at # Hide menu
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
    assert_css('#headermenuholder > .fa-bars')
    screenshot :index, area_size_limit: 533, skip_area: FRONT_PAGE_PROGRESS_BAR_AREA
    find('#headermenuholder > .fa-bars').click
    article_menu_link = find('.menubutton', text: 'My first article')
    screenshot :menu, skip_area: [308, 73, 332, 102]
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
    assert_css('#headermenuholder > .fa-bars')
    assert_css('.fa-chevron-down')
    screenshot :index, area_size_limit: 533, skip_area: FRONT_PAGE_PROGRESS_BAR_AREA
    find('.fa-chevron-down').click
    find('#footer .menu-item a', text: 'MY FIRST ARTICLE')
    screenshot(:scrolled) || (sleep(0.5) if ENV['TRAVIS'])
    assert_equal information_page_url(id(:first)), find('#footer .menu-item a', text: 'MY FIRST ARTICLE')[:href]
    find('#footer .menu-item a', text: 'MY FIRST ARTICLE').click
    assert_current_path information_page_path(id(:first))
    assert_css('h1', text: 'My first article')
    screenshot :article
  end

  private

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
