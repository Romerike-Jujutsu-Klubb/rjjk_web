# frozen_string_literal: true

require 'capybara_setup'

class CanAccessHomeTest < Capybara::Rails::TestCase
  test 'sanity' do
    visit root_path
    assert_content page, 'Velkommen'
    refute_content page, 'Goobye All!'
  end
end
