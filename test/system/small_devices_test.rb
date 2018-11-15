# frozen_string_literal: true

require 'feature_test'

Capybara::Node::Element.class_eval do
  def click_at
    driver.browser.action.move_to(native).click.perform
  end
end

class SmallDevicesTest < FeatureTest
  SMALL_WINDOW_SIZE = [412, 732].freeze

  setup do
    screenshot_section :small_devices
    Capybara::Screenshot.window_size = SMALL_WINDOW_SIZE
    Capybara.current_session.current_window.resize_to(*SMALL_WINDOW_SIZE)
  end

  teardown do
    Capybara::Screenshot.window_size = SystemTestHelper::WINDOW_SIZE
  end

  test 'front_page' do
    screenshot_group :front_page
    visit root_path
    assert_selector 'h1', text: 'Velkommen'
    screenshot :index
    find('.fa-navicon').click
    screenshot :menu
    find('.fa-calendar').click_at
    screenshot :menu_closed
    find('.fa-calendar').click
    screenshot :calendar
    find('.fa-navicon').click_at
    screenshot :calendar_closed
  end
end
