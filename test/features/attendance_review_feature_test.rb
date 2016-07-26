require 'test_helper'

class AttendanceReviewFeatureTest < ActionDispatch::IntegrationTest
  setup {screenshot_section :attendance}

  def test_review_displays_old_attendance
    screenshot_group :review
    visit_with_login "/attendances/review/2013/41/#{group_schedules(:voksne_thursday).id}/I",
        redirected_path: '/mitt/oppmote'
    screenshot('review_old')
    assert_equal ['Forrige uke', 'Trente du? Lars og Newbie trente.', 'Var der! Du og Lars trente.', 'Denne uken', 'Ubekreftet Du trente.', 'Kommer! Du kommer.', 'Neste uke', 'Kommer du?', 'Kommer du?', 'Oktober', '1', "Siden gradering", "3"],
        all('td').map(&:text).reject(&:blank?)

    first('a.btn').click
    assert has_css?('a.btn', text: 'Var der!', count: 2)
    assert_equal ['Forrige uke', 'Var der! Du og 2 andre trente.', 'Var der! Du og Lars trente.', 'Denne uken', 'Ubekreftet Du trente.', 'Kommer! Du kommer.', 'Neste uke', 'Kommer du?', 'Kommer du?', 'Oktober', '1', "Siden gradering", "3"],
        all('td').map(&:text).reject(&:blank?)
    screenshot('with_presence')

    all('a.btn')[1].click
    assert has_css?('a.btn', text: 'Annet')
    assert_equal ['Forrige uke', 'Var der! Du og 2 andre trente.', 'Annet Lars trente.', 'Denne uken', 'Ubekreftet Du trente.', 'Kommer! Du kommer.', 'Neste uke', 'Kommer du?', 'Kommer du?', 'Oktober', '1', "Siden gradering", "3"],
        all('td').map(&:text).reject(&:blank?)
    screenshot('with_absence')

    first('a', text: 'Du og 2 andre').click
    screenshot('popup')
  end
end
