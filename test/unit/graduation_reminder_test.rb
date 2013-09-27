require 'test_helper'

class GraduationReminderTest < ActionMailer::TestCase
  def test_notify_missing_graduations
    GraduationReminder.notify_missing_graduations

    assert_equal 1, Mail::TestMailer.deliveries.size
    mail = Mail::TestMailer.deliveries[0]
    assert_equal %w(uwe@kubosch.no), mail.to_addrs
    assert_match /Hei Uwe.*Panda mangler gradering for dette semesteret/m, mail.encoded
  end
end
