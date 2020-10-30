# frozen_string_literal: true

require 'application_system_test_case'

class NextPracticeSystemTest < ApplicationSystemTestCase
  test 'next practice' do
    visit root_path
    assert_selector 'h1,h2', text: 'Trening - Teknikk - Trygghet'
    assert_no_selector 'h4', text: 'Neste trening'
    screenshot :anonymous
    login
    assert_selector 'h4', text: 'Neste trening'
    assert_text 'Du kommer.'
    screenshot :logged_in

    practice = practices(:voksne_2013_42_thursday)
    practice.attendances.create! user_id: id(:lars), status: 'X'
    practice.attendances.create! user_id: id(:newbie), status: 'X'
    visit root_path
    screenshot :with_others

    first(:link, 'Du og 2 andre').click
    assert_selector 'h5', text: 'Påmeldt'
    assert_selector 'li', text: 'Uwe Kubosch'
    screenshot :modale, skip_area: [734, 115, 735, 162]
  end
end
