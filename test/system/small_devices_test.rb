# frozen_string_literal: true

require 'application_system_test_case'

class SmallDevicesTest < ApplicationSystemTestCase
  SMALL_WINDOW_SIZE = [412, 732].freeze
  PROGRESS_BAR_AREA = [0, 700, 320, 32].freeze

  setup do
    screenshot_section :small_devices
    Capybara::Screenshot.window_size = SMALL_WINDOW_SIZE
    Capybara.current_session.current_window.resize_to(*SMALL_WINDOW_SIZE)
  end

  teardown do
    Capybara::Screenshot.window_size = ApplicationSystemTestCase::WINDOW_SIZE
  end

  test 'member front_page' do
    screenshot_group :front_page
    login_and_visit root_path
    assert_selector 'h4', text: 'Neste trening'
    screenshot :index
    find('.fa-bars').click
    assert_selector 'li a', text: 'My first article'
    assert_css '#menuShadow', visible: :visible
    find('.fa-calendar-alt').hover # FIXME(uwe): Remove with Chrome 74 + mobile emulation
    screenshot :menu
    find('.fa-calendar-alt').click_at
    assert_css '#menuShadow', visible: :hidden
    screenshot :menu_closed

    begin
      find('.fa-calendar-alt').click
    rescue
      tries ||= 1
      raise "fa-calendar-alt click failed (#{tries}): #{$ERROR_INFO}" if tries >= 6

      sleep 0.001
      tries += 1
      retry
    end

    screenshot :calendar
    find('.fa-bars').click_at
    screenshot :calendar_closed
  end

  test 'new front_page' do
    screenshot_group :new_front_page
    visit front_page_path
    assert_selector 'h5', text: 'THE EVENT'
    assert_css('#headermenuholder > .fa-bars')
    screenshot :index, color_distance_limit: 11
    find('#headermenuholder > .fa-bars').click
    article_menu_link = find('.menubutton', text: 'My first article')
    article_menu_link.hover
    screenshot :menu
    begin
      article_menu_link.click
    rescue => e
      tries ||= 1
      raise "article menu click failed (#{tries}): #{e}" if tries >= 6

      sleep 0.001
      tries += 1
      retry
    end

    screenshot :article
  end

  test 'new front page scroll' do
    screenshot_group :new_front_page_scroll
    visit front_page_path
    assert_css('#headermenuholder > .fa-bars')
    assert_css('.fa-chevron-down')
    screenshot :index, color_distance_limit: 11
    find('.fa-chevron-down').click
    begin
      article_link = find('#footer .menu-item a', text: 'MY FIRST ARTICLE')
    rescue => e
      tries ||= 1
      raise "finding article link failed (#{tries}): #{e}" if tries >= 6

      sleep 0.001
      tries += 1
      retry
    end
    screenshot(:scrolled, skip_area: PROGRESS_BAR_AREA) || (sleep(0.5) if ENV['TRAVIS'])
    begin
      article_link.click
      assert_css('h1', text: 'My first article')
    rescue Minitest::Assertion => e
      tries ||= 1
      raise "article link click failed (#{tries}): #{e}" if tries >= 6

      sleep 0.001
      tries += 1
      retry
    end
    screenshot :article
  end
end
