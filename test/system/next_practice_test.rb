# frozen_string_literal: true

require 'application_system_test_case'

class NextPracticeTest < ApplicationSystemTestCase
  setup { screenshot_section :next_practice }
  test 'next practice' do
    screenshot_group :next_practice
    visit root_url
    assert_no_selector 'h4', text: 'Neste trening'
    screenshot :anonymous
    login
    assert_selector 'h4', text: 'Neste trening'
    assert_text 'Du kommer.'
    screenshot :logged_in

    practice = practices(:voksne_2013_42_thursday)
    practice.attendances.create! member_id: id(:lars), status: 'X'
    practice.attendances.create! member_id: id(:newbie), status: 'X'
    visit root_url
    screenshot :with_others

    click_on 'Du og 2 andre'
    assert_selector 'h5', text: 'Påmeldt'
    assert_selector 'li', text: 'Uwe Kubosch'
    screenshot :modale
  end
end
