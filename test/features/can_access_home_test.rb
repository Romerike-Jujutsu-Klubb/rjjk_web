# frozen_string_literal: true

require 'feature_test'

class CanAccessHomeTest < FeatureTest
  setup { screenshot_section :home }

  test 'front' do
    screenshot_group :front
    visit root_path
    assert_selector 'h1', text: 'Velkommen'
    screenshot :index
  end
end
