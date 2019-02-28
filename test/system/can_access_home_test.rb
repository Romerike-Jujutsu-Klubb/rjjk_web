# frozen_string_literal: true

require 'application_system_test_case'

class CanAccessHomeTest < ApplicationSystemTestCase
  setup { screenshot_section :home }

  test 'front' do
    screenshot_group :front
    visit root_path
    assert_selector 'h1', text: 'Velkommen'
    screenshot :index
  end
end
