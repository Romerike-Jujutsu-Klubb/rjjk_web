# frozen_string_literal: true

require 'application_system_test_case'

class AttendancePlanFeatureTest < ApplicationSystemTestCase
  setup do
    screenshot_section :attendance
    visit_with_login '/mitt/oppmote'
  end

  def test_plan
    screenshot_group :plan
    screenshot('index')
    assert_equal ['Denne uken', "Ubekreftet\nDu trente.", "Kommer!\nDu kommer.",
                  'Neste uke', 'Kommer du?', 'Kommer du?', 'Oktober', '1',
                  'Siden gradering', '1'],
        all('td').map(&:text).reject(&:blank?)

    first('table a.btn').click
    assert_css('a.btn', text: 'Trente!')
    assert_equal(['Denne uken', 'Trente! Du trente.', 'Kommer! Du kommer.',
                  'Neste uke', 'Kommer du?', 'Kommer du?', 'Oktober', '1',
                  'Siden gradering', '1'],
        all('td').map(&:text).reject(&:blank?).map(&:strip).map { |s| s.gsub(/\s+/, ' ') })

    first('table a.btn').click
    assert_css('a.btn', text: 'Forhindret')
    assert_equal(['Denne uken', 'Forhindret', 'Kommer! Du kommer.', 'Neste uke',
                  'Kommer du?', 'Kommer du?', 'Oktober', '1', 'Siden gradering', '1'],
        all('td').map(&:text).reject(&:blank?).map(&:strip).map { |s| s.gsub(/\s+/, ' ') })

    all('table a.btn')[1].click
    assert_css 'a.btn', text: 'Kommer du?', count: 2
    assert_css 'a.btn', text: 'Trener!'
    assert_equal [
      'Denne uken', 'Forhindret', "Trener!\nDu kommer.",
      'Neste uke', 'Kommer du?', 'Kommer du?',
      'Oktober', '1', 'Siden gradering', '1'
    ], all('td').map(&:text).reject(&:blank?)

    all('table a.btn')[1].click
    assert_css('a.btn', text: 'Kommer du?', count: 2)
    assert_equal(['Denne uken', 'Forhindret', 'Forhindret', 'Neste uke',
                  'Kommer du?', 'Kommer du?', 'Oktober', '1', 'Siden gradering', '1'],
        all('td').map(&:text).reject(&:blank?).map(&:strip).map { |s| s.gsub(/\s+/, ' ') })
  end

  def test_dropdown_changes_are_persistent
    screenshot_group :persistence
    next_button = find("#button_2013_42_545305079_#{id :uwe}")
    assert_equal 'Kommer!', next_button.text
    next_button.find('button.dropdown-toggle').click
    assert_equal 'Kommer!
Kommer!
Trener!
Instruere
Bortreist
Sykdom
Forhindret', next_button.text
    screenshot('dropdown')
    next_button.click_link('Forhindret')
    assert_equal 'Forhindret', next_button.text
    wait_for_ajax
    visit "/mitt/oppmote?a=#{Time.current.to_i}"
    next_button = find("#button_2013_42_545305079_#{id :uwe}")
    assert_equal 'Forhindret', next_button.text
  end
end
