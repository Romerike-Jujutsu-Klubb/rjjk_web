# frozen_string_literal: true

require 'application_system_test_case'

class EventsTest < ApplicationSystemTestCase
  setup { screenshot_section :events }

  test 'edit' do
    screenshot_group :edit
    login
    visit events_url
    assert_selector 'h1', text: 'Arrangement'
    screenshot :index
    click_on 'THE EVENT'
    screenshot :description
    click_on 'Lagre'
    screenshot :saved
    find('a', text: 'Deltagere').click
    screenshot :participants
    click_on 'Legg til'
    screenshot :added_groups
  end
end
