# frozen_string_literal: true

require 'feature_test'

class NextPracticeAttendanceFeatureTest < FeatureTest
  setup { login_and_visit '/' }

  def test_announce_attendance
    screenshot('next_practice/initial')
    find('#next_practice i.fa-thumbs-down').click
    screenshot('next_practice/absence')
    find('#next_practice i.fa-thumbs-up').click
    screenshot('next_practice/will_attend')
  end
end
