# frozen_string_literal: true

require 'application_system_test_case'

class FrontPageSystemTest < ApplicationSystemTestCase
  setup { screenshot_section :home }

  test 'front' do
    screenshot_group :front
    visit root_path
    assert_selector 'h5', text: 'ARRANGEMENTET'
    assert_selector 'h2', text: 'Section 1'
    find('.newwrap').assert_matches_style(opacity: '1')
    screenshot :index, skip_area: FRONT_PAGE_PROGRESS_BAR_AREA
  end

  test 'new front' do
    screenshot_group :new_front
    visit front_page_path
    assert_selector '#navigation'
    assert_selector 'h2', text: 'Section 1'
    find('.newwrap').assert_matches_style(opacity: '1')
    screenshot :index, color_distance_limit: 175
    find('.fa-chevron-down').click
    with_retries { assert_equal 518, evaluate_script('$("html").scrollTop()') }
    screenshot :footer, color_distance_limit: 175
  end
end
