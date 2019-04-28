# frozen_string_literal: true

require 'application_system_test_case'

class SmallDevicesTest < ApplicationSystemTestCase
  SMALL_WINDOW_SIZE = [412, 732].freeze

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
    find('.fa-navicon').click
    assert_selector 'li a', text: 'My first article'
    assert_css '#menuShadow', visible: :visible
    find('.fa-calendar').hover # FIXME(uwe): Remove with Chrome 74 + mobile emulation
    screenshot :menu
    find('.fa-calendar').click_at
    assert_css '#menuShadow', visible: :hidden
    screenshot :menu_closed

    begin
      find('.fa-calendar').click
    rescue
      tries ||= 1
      raise "fa-calendar click failed (#{tries}): #{$ERROR_INFO}" if tries >= 6

      sleep 0.001
      tries += 1
      retry
    end

    screenshot :calendar
    find('.fa-navicon').click_at
    screenshot :calendar_closed
  end

  test 'new front_page' do
    screenshot_group :new_front_page
    visit front_page_path
    assert_selector 'h5', text: 'THE EVENT'
    assert_css('#headermenuholder > i')
    screenshot :index, color_distance_limit: 11
    find('#headermenuholder > i').click
    article_menu_link = find('.menubutton', text: 'My first article')
    article_menu_link.hover
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

    screenshot :article
  end

  test 'new front page scroll' do
    skip 'Enable when Chrome 74 is stable' if ENV['TRAVIS'] # FIXME(uwe): Enable when Chrome 74 is stable
    screenshot_group :new_front_page_scroll
    visit front_page_path
    assert_css('#headermenuholder > i')
    assert_css('.fa-chevron-down')
    screenshot :index, color_distance_limit: 11
    find('.fa-chevron-down').click
    article_link = find('#footer .menu-item a', text: 'MY FIRST ARTICLE')
    # FIXME(uwe): Ignore bottom slider progress bar
    screenshot :scrolled, area_size_limit: 4 # , skip_area: [left: 0, bottom: 0, width: 320, height: 60]
    article_link.click
    assert_css('h1', text: 'My first article')
    screenshot :article
  end
end
