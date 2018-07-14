require "application_system_test_case"

Capybara::Node::Element.class_eval do
  def click_at
    driver.browser.action.move_to(native).click.perform
  end
end

class SmallDevicesTest < ApplicationSystemTestCase
  setup { screenshot_section :small_devices }

  test "front_page" do
    screenshot_group :front_page
    Capybara.current_session.current_window.resize_to(412, 732)
    visit root_url
    assert_selector "h1", text: "Velkommen"
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
