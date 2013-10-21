require 'test_helper'

class NkfMemberTrialReminderTest < ActionMailer::TestCase
  def test_notify_overdue_trials
    NkfMemberTrialReminder.notify_overdue_trials
    assert_equal 1, Mail::TestMailer.deliveries.size
    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK][test] Utløpt prøvetid', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match "Følgende prøvemedlemmer har utløpt prøvetid:\r\n\r\n<ul>\r\n    <li>MyString MyString</li>\r\n    <li>MyString MyString</li>\r\n</ul>", mail.body.encoded
  end

  def test_send_waiting_lists
    NkfMemberTrialReminder.send_waiting_lists
    assert_equal 1, Mail::TestMailer.deliveries.size
    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK][test] Ventelister', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match "Følgende grupper har folk på venteliste:\r\n\r\n<ul>\r\n</ul>", mail.body.encoded
  end

end
