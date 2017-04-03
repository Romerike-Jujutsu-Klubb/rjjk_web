# frozen_string_literal: true

require 'test_helper'

class SemesterReminderTest < ActionMailer::TestCase
  test 'notify_missing_semesters this semester' do
    GroupInstructor.delete_all
    GroupSemester.delete_all
    Semester.delete_all
    assert_difference('Semester.count') { SemesterReminder.create_missing_semesters }
  end

  test 'notify_missing_semesters next semester' do
    GroupInstructor.delete_all
    GroupSemester.delete_all
    Semester.where('end_on > ?', 4.months.from_now).delete_all
    assert_difference('Semester.count') { SemesterReminder.create_missing_semesters }
  end

  test 'notify_missing_semesters without missing semesters' do
    assert_no_difference('Semester.count') { SemesterReminder.create_missing_semesters }
  end

  test 'notify_missing_session_dates' do
    assert_mail_stored(0) { SemesterReminder.notify_missing_session_dates }
  end
end
