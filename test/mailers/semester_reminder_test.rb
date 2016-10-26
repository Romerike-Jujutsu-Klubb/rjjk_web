# frozen_string_literal: true
require 'test_helper'

class SemesterReminderTest < ActionMailer::TestCase
  test 'notify_missing_semesters' do
    assert_mail_stored(0) { SemesterReminder.notify_missing_semesters }
  end

  test 'notify_missing_session_dates' do
    assert_mail_stored(0) { SemesterReminder.notify_missing_session_dates }
  end
end
