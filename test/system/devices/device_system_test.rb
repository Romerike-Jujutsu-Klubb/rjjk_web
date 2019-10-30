# frozen_string_literal: true

require 'application_system_test_case'

module DeviceSystemTest
  extend ActiveSupport::Concern

  MENU_BTN_AREA = [130, 20, 142, 63].freeze
  SUBNAV_OFFSET = -268

  included do
    cattr_accessor :logo_area
    cattr_accessor :menu_logo_area
    cattr_accessor :progress_bar_area
    cattr_accessor :scroll_bar_area
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

    def use_device(name, window_size:, menu_logo_area:, logo_area:)
      self.scroll_bar_area = [window_size[0] - 19, 0, window_size[0] - 6, window_size[1] - 1]
      self.progress_bar_area = [0, window_size[1] - 8, window_size[0] - 1, window_size[1] - 1]
      self.menu_logo_area = menu_logo_area
      self.logo_area = logo_area
      Capybara.register_driver driver_name do |app|
        browser_options = ::Selenium::WebDriver::Chrome::Options.new
        browser_options.args << '--force-color-profile=srgb'
        browser_options.add_emulation(device_name: name)
        browser_options.headless!
        Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
      end

      driven_by driver_name
    end
  end

  def test_member_front_page
    screenshot_group :front_page
    login_and_visit root_path
    assert_selector 'h4', text: 'Neste trening'
    assert_offset '.subnav', :left, SUBNAV_OFFSET
    assert_offset '.main_right', :right, SUBNAV_OFFSET
    bottom_logo_area = [703, 1820, 703, 1852]
    screenshot :index, skip_area: [logo_area, bottom_logo_area]
    find('.fa-bars').click # Display menu
    assert_offset '.subnav', :left, 0
    assert_selector 'li a', text: 'My first article'
    find('h1', text: 'Instruksjon').hover
    assert_css '#menuShadow'
    screenshot :menu, skip_area: logo_area
    find('.fa-calendar-alt').click_at # Hide menu
    assert_offset '.subnav', :left, SUBNAV_OFFSET
    assert_no_css '#menuShadow'
    screenshot :menu_closed, skip_area: [logo_area, bottom_logo_area]

    find('#calendarBtn').click # Display calendar sidebar
    assert_offset '.main_right', :right, 0
    assert_css '#sidebarShadow'
    screenshot :calendar, skip_area: logo_area, area_size_limit: 18
    find('#sidebarShadow').click(x: 10, y: 10) # Hide calendar sidebar
    assert_offset '.main_right', :right, SUBNAV_OFFSET
    assert_no_css '#sidebarShadow'
    screenshot :calendar_closed, skip_area: [logo_area, bottom_logo_area]
  end

  def test_new_front_page
    screenshot_group :new_front_page
    visit front_page_path
    assert_css('#headermenuholder > .fa-bars')
    screenshot :index, skip_area: [MENU_BTN_AREA, self.class.progress_bar_area]
    find('#headermenuholder > .fa-bars').click
    article_menu_link = find('.menubutton', text: 'My first article')
    screenshot :menu, skip_area: menu_logo_area
    with_retries(label: 'article menu click') { article_menu_link.click }
    assert_css 'h1', text: 'My first article'
    screenshot :article, skip_area: logo_area
  end

  def test_new_front_page_scroll
    screenshot_group :new_front_page_scroll
    visit front_page_path
    assert_css('#headermenuholder > .fa-bars')
    assert_css('.fa-chevron-down')
    screenshot :index, area_size_limit: 533, skip_area: [MENU_BTN_AREA, self.class.progress_bar_area]
    find('.fa-chevron-down').click
    find('#footer .menu-item a', text: 'MY FIRST ARTICLE')
    screenshot(:scrolled, skip_area: self.class.scroll_bar_area)
    assert_equal information_page_url(id(:first)),
        find('#footer .menu-item a', text: 'MY FIRST ARTICLE')[:href]
    with_retries label: 'article link click' do
      find('#footer .menu-item a', text: 'MY FIRST ARTICLE').click
      assert_current_path information_page_path(id(:first))
    end

    assert_css('h1', text: 'My first article')
    screenshot :article, skip_area: logo_area
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
