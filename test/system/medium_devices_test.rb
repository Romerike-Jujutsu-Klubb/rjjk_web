# frozen_string_literal: true

require 'application_system_test_case'

class MediumDevicesTest < ApplicationSystemTestCase
  MEDIUM_WINDOW_SIZE = [640, 480].freeze

  Capybara.register_driver :chrome_medium do |app|
    browser_options = ::Selenium::WebDriver::Chrome::Options.new
    browser_options.args << '--force-device-scale-factor=1'
    browser_options.args << '--headless'
    browser_options.args << '--use-fake-ui-for-media-stream'
    browser_options.add_emulation(
        device_metrics: { width: 640, height: 480, pixelRatio: 1, touch: true }, user_agent: <<~UA )
          Mozilla/5.0 (Linux; Android 6.0.1; Nexus 7 Build/MOB30X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.119 Safari/537.36
        UA
    # browser_options.add_emulation( device_name: 'Nexus 7')
    # browser_options.headless!
    # browser_options.add_emulation( device_name: 'iPad')
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
  end

  driven_by :chrome_medium

  setup do
    screenshot_section :medium_devices
    Capybara::Screenshot.window_size = nil
  end

  teardown do
    Capybara::Screenshot.window_size = ApplicationSystemTestCase::WINDOW_SIZE
  end

  test 'front_page' do
    screenshot_group :front_page
    visit root_path
    assert_selector 'h1', text: 'Velkommen'
    screenshot :index
    find('.fa-navicon').click
    assert_selector 'li a', text: 'My first article'
    screenshot :menu
    find('.fa-calendar').click_at
    screenshot :menu_closed
    find('.fa-calendar').click
    screenshot :calendar
    find('.fa-navicon').click_at
    screenshot :calendar_closed
  end

  test 'new front_page' do
    screenshot_group :new_front_page
    visit front_page_path
    assert_css('#headermenuholder > i')
    screenshot :index, color_distance_limit: 11
    find('#headermenuholder > i').click
    assert_selector '.menubutton', text: 'My first article'
    find('.menubutton', text: 'My first article').hover
    screenshot :menu
    find('menu a', text: 'My first article').click
    screenshot :article
  end

  test 'new front page scroll' do
    screenshot_group :new_front_page_scroll
    visit front_page_path
    assert_css('#headermenuholder > i')
    assert_css('.fa-chevron-down')
    screenshot :index
    find('.fa-chevron-down').click
    article_link = find('#footer .menu-item a', text: 'MY FIRST ARTICLE')
    screenshot :scrolled, area_size_limit: 4, color_distance_limit: 49 # FIXME(uwe): Ignore bottom slider progress bar
    article_link.click
    assert_css('h1', text: 'My first article')
    screenshot :article
  rescue
    skip 'FIXME' if ENV['TRAVIS']
  end
end
