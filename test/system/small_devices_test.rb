# frozen_string_literal: true

require 'application_system_test_case'

class SmallDevicesTest < ApplicationSystemTestCase
  SMALL_WINDOW_SIZE = [412, 732].freeze
  PROGRESS_BAR_AREA = [0, 700, 320, 32].freeze
  SCROLL_BAR_AREA = [403, 338, 409, 341].freeze

  setup do
    screenshot_section :small_devices
    Capybara::Screenshot.window_size = SMALL_WINDOW_SIZE
    Capybara.current_session.current_window.resize_to(*SMALL_WINDOW_SIZE)
    @original_skip_area = Capybara::Screenshot::Diff.skip_area
    Capybara::Screenshot::Diff.skip_area = SCROLL_BAR_AREA
  end

  teardown do
    Capybara::Screenshot::Diff.skip_area = @original_skip_area
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
    with_retries(label: 'fa-calendar-alt click') { find('.fa-calendar-alt').click }
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
    with_retries(label: 'article menu click') { article_menu_link.click }
    screenshot :article
  end

  test 'new front page scroll' do
    screenshot_group :new_front_page_scroll
    visit front_page_path
    assert_css('#headermenuholder > .fa-bars')
    chevron_btn = find('.fa-chevron-down')
    screenshot :index, color_distance_limit: 11
    chevron_btn.click
    article_link = find('#footer .menu-item a', text: 'MY FIRST ARTICLE')

    # with_retries(label: 'article link in view') do
    #   in_view = evaluate_script(<<~JS, article_link)
    #     (function(el) {
    #       var rect = el.getBoundingClientRect();
    #       return (
    #         rect.top >= 0 && rect.left >= 0 &&
    #         rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
    #         rect.right <= (window.innerWidth || document.documentElement.clientWidth)
    #       )
    #     })(arguments[0]);
    #   JS
    #   assert in_view
    # end

    screenshot(:scrolled, skip_area: [SCROLL_BAR_AREA, PROGRESS_BAR_AREA])
    with_retries(label: 'article link click') do # FIXME(uwe): Remove this retry, and fix scrolling
      article_link.click
      assert_css('h1', text: 'My first article', wait: 0.6)
    end
    screenshot :article
  end
end
