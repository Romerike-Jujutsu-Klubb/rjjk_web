# frozen_string_literal: true

require 'application_system_test_case'

class FrontPageSystemTest < ApplicationSystemTestCase
  setup { screenshot_section :home }

  test 'front' do
    screenshot_group :front
    visit root_path
    assert_selector 'h5', text: 'ARRANGEMENTET'
    assert_selector 'h1,h2', text: 'Trening - Teknikk - Trygghet'
    screenshot :index
  end
end
