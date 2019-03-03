# frozen_string_literal: true

require 'application_system_test_case'

Capybara::Node::Element.class_eval do
  def click_at
    driver.browser.action.move_to(native).click.perform
  end
end

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
    assert_css('#headermenuholder > i', visible: true)
    screenshot :index, color_distance_limit: 11
    find('#headermenuholder > i').click
    assert_selector '.menubutton', text: 'My first article'
    screenshot :menu
    find('menu a', text: 'My first article').click
    screenshot :article
  end

  test 'new front page scroll' do
    screenshot_group :new_front_page_scroll
    visit front_page_path
    assert_css('#headermenuholder > i')
    assert_css('.fa-chevron-down')
    screenshot :index, color_distance_limit: 11
    find('.fa-chevron-down').click
    article_link = find('#footer .menu-item a', text: 'MY FIRST ARTICLE')
    screenshot :scrolled, area_size_limit: 4, color_distance_limit: 49 # FIXME(uwe): Ignore bottom slider progress bar
    article_link.click
    assert_css('h1', text: 'My first article')
    screenshot :article
  end
end
