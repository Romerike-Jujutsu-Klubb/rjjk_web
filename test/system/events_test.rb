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
    click_on 'ARRANGEMENTET', match: :first
    screenshot :description
    click_on 'Lagre'
    screenshot :saved
    find('a', text: 'Deltagere').click
    screenshot :participants
    find('a', text: 'Grupper').click
    screenshot :groups
    click_on 'Legg til grupper'
    screenshot :added_groups
  end

  test 'participants tab directly' do
    screenshot_group :participants_tab_directly
    login
    visit edit_event_path id(:one), anchor: :invitees_tab
    screenshot :participants
  end
end
