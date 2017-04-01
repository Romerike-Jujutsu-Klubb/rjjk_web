# frozen_string_literal: true

require 'capybara_setup'

class AttendanceReviewFeatureTest < ActionDispatch::IntegrationTest
  setup { screenshot_section :attendance }

  def test_review_displays_old_attendance
    screenshot_group :review
    visit_with_login "/attendances/review/2013/41/#{group_schedules(:voksne_thursday).id}/I",
        redirected_path: '/mitt/oppmote'
    screenshot('review_old')
    assert has_css?('td', count: 13)
    assert_equal ['Forrige uke', 'Trente du? Lars og Newbie trente.',
        'Trente! Du og Lars trente.', 'Denne uken', 'Ubekreftet Du trente.',
        'Kommer! Du kommer.', 'Neste uke', 'Kommer du?', 'Kommer du?',
        'Oktober', '1', 'Siden gradering', '3'],
        all('td').map(&:text).reject(&:blank?)

    first('a.btn').click
    assert has_css?('a.btn', text: 'Trente!', count: 2)
    assert_equal ['Forrige uke', 'Trente! Du og 2 andre trente.',
        'Trente! Du og Lars trente.', 'Denne uken', 'Ubekreftet Du trente.',
        'Kommer! Du kommer.', 'Neste uke', 'Kommer du?', 'Kommer du?',
        'Oktober', '1', 'Siden gradering', '3'],
        all('td').map(&:text).reject(&:blank?)
    screenshot('with_presence')

    all('a.btn')[1].click
    wait_for_ajax
    assert has_css?('a.btn', text: 'Annet')
    assert_equal ['Forrige uke', 'Trente! Du og 2 andre trente.',
        'Annet Lars trente.', 'Denne uken', 'Ubekreftet Du trente.',
        'Kommer! Du kommer.', 'Neste uke', 'Kommer du?', 'Kommer du?',
        'Oktober', '1', 'Siden gradering', '3'],
        all('td').map(&:text).reject(&:blank?)
    screenshot('with_absence')

    first('a', text: 'Du og 2 andre').click
    screenshot('popup')
  end
end
