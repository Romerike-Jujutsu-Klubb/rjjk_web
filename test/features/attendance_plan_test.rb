require 'test_helper'

class AttendancePlanTest < ActionDispatch::IntegrationTest
  setup { visit_with_login '/mitt/oppmote' }

  def test_plan
    screenshot('attendance/plan/index')
    assert_equal ['Denne uken', 'Ubekreftet', 'Kommer!', 'Neste uke', 'Kommer du?', 'Kommer du?', 'Oktober', '1', 'Siden gradering', '3'],
        all('td').map(&:text).reject(&:blank?)

    first('a.btn').click
    assert has_css?('a.btn', text: 'Var der!')
    assert_equal ['Denne uken', 'Var der!', 'Kommer!', 'Neste uke', 'Kommer du?', 'Kommer du?', 'Oktober', '1', 'Siden gradering', '3'],
        all('td').map(&:text).reject(&:blank?)

    first('a.btn').click
    assert has_css?('a.btn', text: 'Annet')
    assert_equal ['Denne uken', 'Annet', 'Kommer!', 'Neste uke', 'Kommer du?', 'Kommer du?', 'Oktober', '1', 'Siden gradering', '3'],
        all('td').map(&:text).reject(&:blank?)

    all('a.btn')[1].click
    assert has_css?('a.btn', text: 'Kommer du?', count: 3), all('a.btn').map(&:text)
    assert_equal ['Denne uken', 'Annet', 'Kommer du?', 'Neste uke', 'Kommer du?', 'Kommer du?', 'Oktober', '1', 'Siden gradering', '3'],
        all('td').map(&:text).reject(&:blank?)

    all('a.btn')[1].click
    assert has_css?('a.btn', text: 'Kommer du?', count: 2)
    assert_equal ['Denne uken', 'Annet', 'Kommer!', 'Neste uke', 'Kommer du?', 'Kommer du?', 'Oktober', '1', 'Siden gradering', '3'],
        all('td').map(&:text).reject(&:blank?)
  end

  def test_dropdown_changes_are_persistent
    next_button = find('#button_2013_42_545305079')
    assert_equal 'Kommer!', next_button.text
    next_button.find('span.caret').click
    screenshot('attendance/plan/dropdown')
    next_button.click_link('Annet')
    assert_equal 'Annet', next_button.text
    wait_for_ajax
    visit "/mitt/oppmote?a=#{Time.now.to_i}"
    next_button = find('#button_2013_42_545305079')
    assert_equal 'Annet', next_button.text
  end

end
