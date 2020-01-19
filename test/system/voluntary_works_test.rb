# frozen_string_literal: true

require 'application_system_test_case'

class VoluntaryWorksTest < ApplicationSystemTestCase
  setup { screenshot_section :voluntary_works }

  test 'edit' do
    screenshot_group :edit
    login
    visit events_url(anchor: 'past_tab')
    assert_selector 'h1', text: 'Arrangement'
    screenshot :index
    click_on 'Vaskedugnad'
    screenshot :description
    click_on 'Lagre'
    screenshot :saved
    find('a', text: 'Deltagere').click
    screenshot :participants
    click_on 'Legg til grupper'
    screenshot :added_groups
  end
end
