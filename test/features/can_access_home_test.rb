# frozen_string_literal: true

require 'feature_test'

class CanAccessHomeTest < FeatureTest
  test 'sanity' do
    visit root_path
    assert_selector 'h1', text: 'Velkommen'
  end
end
