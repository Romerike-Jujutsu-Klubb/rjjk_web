# frozen_string_literal: true

require 'application_system_test_case'

class NextPracticeAttendanceFeatureTest < ApplicationSystemTestCase
  setup do
    screenshot_section :next_practice
    login_and_visit '/'
  end

  def test_announce_attendance
    screenshot_group :announce_attendance
    screenshot :initial
    first('.next_practice i.fa-thumbs-down').click
    screenshot :absence
    first('.next_practice i.fa-thumbs-up').click
    screenshot :will_attend
  end
end
