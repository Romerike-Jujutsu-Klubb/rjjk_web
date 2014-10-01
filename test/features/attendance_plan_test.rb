require 'test_helper'

class AttendancePlanTest < ActionDispatch::IntegrationTest
  def test_plan
    visit_with_login '/mitt/oppmote'
    screenshot('attendance/plan/index')
    assert_equal ['Ubekreftet', 'Kommer!', 'Kommer du?', 'Kommer du?', 'Oktober', '1'],
        all('td').map(&:text).reject(&:blank?)

    first('a.btn').click
    assert has_css?('a.btn', text: 'Var der!')
    assert_equal ['Var der!', 'Kommer!', 'Kommer du?', 'Kommer du?', 'Oktober', '1'],
        all('td').map(&:text).reject(&:blank?)

    first('a.btn').click
    assert has_css?('a.btn', text: 'Annet')
    assert_equal ['Annet', 'Kommer!', 'Kommer du?', 'Kommer du?', 'Oktober', '1'],
        all('td').map(&:text).reject(&:blank?)

    all('a.btn')[1].click
    assert has_css?('a.btn', text: 'Kommer du?', count: 3), all('a.btn').map(&:text)
    assert_equal ['Annet', 'Kommer du?', 'Kommer du?', 'Kommer du?', 'Oktober', '1'],
        all('td').map(&:text).reject(&:blank?)

    all('a.btn')[1].click
    assert has_css?('a.btn', text: 'Kommer du?', count: 2)
    assert_equal ['Annet', 'Kommer!', 'Kommer du?', 'Kommer du?', 'Oktober', '1'],
        all('td').map(&:text).reject(&:blank?)
  end

  def test_dropdown_changes_are_persistent
    visit_with_login '/mitt/oppmote'
    next_button = find('#button_42_545305079')
    assert_equal 'Kommer!', next_button.text
    next_button.find('span.caret').click
    next_button.click_link('Annet')
    assert_equal 'Annet', next_button.text
    wait_for_ajax
    visit "/mitt/oppmote?a=#{Time.now.to_i}"
    next_button = find('#button_42_545305079')
    assert_equal 'Annet', next_button.text
  end

  def test_review_displays_old_attendance
    visit_with_login "/attendances/review/2013/41/#{group_schedules(:voksne_thursday).id}/I",
        redirected_path: '/mitt/oppmote'
    screenshot('attendance/plan/review_old')
    assert_equal ['Trente du? Lars trente.', 'Var der! Lars trente.', 'Ubekreftet', 'Kommer!', 'Kommer du?', 'Kommer du?'],
        all('td').map(&:text).reject(&:blank?)

    first('a.btn').click
    assert has_css?('a.btn', text: 'Var der!', count: 2)
    assert_equal ['Var der! Lars trente.', 'Var der! Lars trente.', 'Ubekreftet', 'Kommer!', 'Kommer du?', 'Kommer du?'],
        all('td').map(&:text).reject(&:blank?)

    all('a.btn')[1].click
    assert has_css?('a.btn', text: 'Annet')
    assert_equal ['Var der! Lars trente.', 'Annet Lars trente.', 'Ubekreftet', 'Kommer!', 'Kommer du?', 'Kommer du?'],
        all('td').map(&:text).reject(&:blank?)
  end

end
