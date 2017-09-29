# frozen_string_literal: true

require 'feature_test'

class CanAccessHomeTest < Capybara::Rails::TestCase
  test 'sanity' do
    visit root_path
    assert_content page, 'Velkommen'
    refute_content page, 'Goobye All!'
  end
end
