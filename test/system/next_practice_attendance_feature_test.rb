# frozen_string_literal: true

require 'application_system_test_case'

class NextPracticeAttendanceFeatureTest < ApplicationSystemTestCase
  setup { login_and_visit '/' }

  def test_announce_attendance
    screenshot('next_practice/initial')
    find('#next_practice i.fa-thumbs-down').click
    screenshot('next_practice/absence')
    find('#next_practice i.fa-thumbs-up').click
    screenshot('next_practice/will_attend')
  end
end
