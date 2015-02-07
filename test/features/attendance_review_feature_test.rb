require 'test_helper'

class AttendanceReviewFeatureTest < ActionDispatch::IntegrationTest
  def test_review_displays_old_attendance
    visit_with_login "/attendances/review/2013/41/#{group_schedules(:voksne_thursday).id}/I",
        redirected_path: '/mitt/oppmote'
    screenshot('attendance/plan/review_old')
    assert_equal ['Forrige uke', 'Trente du? Lars trente.', 'Var der! Du og Lars trente.', 'Denne uken', 'Ubekreftet', 'Kommer!', 'Neste uke', 'Kommer du?', 'Kommer du?', 'Oktober', '1'],
        all('td').map(&:text).reject(&:blank?)

    first('a.btn').click
    assert has_css?('a.btn', text: 'Var der!', count: 2)
    assert_equal ['Forrige uke', 'Var der! Du og Lars trente.', 'Var der! Du og Lars trente.', 'Denne uken', 'Ubekreftet', 'Kommer!', 'Neste uke', 'Kommer du?', 'Kommer du?', 'Oktober', '1'],
        all('td').map(&:text).reject(&:blank?)

    all('a.btn')[1].click
    assert has_css?('a.btn', text: 'Annet')
    assert_equal ['Forrige uke', 'Var der! Du og Lars trente.', 'Annet Lars trente.', 'Denne uken', 'Ubekreftet', 'Kommer!', 'Neste uke', 'Kommer du?', 'Kommer du?', 'Oktober', '1'],
        all('td').map(&:text).reject(&:blank?)

    screenshot('dummy')
    first('a', text: 'Du og Lars').click
    screenshot('attendance/plan/review_old_popup')
  end
end
