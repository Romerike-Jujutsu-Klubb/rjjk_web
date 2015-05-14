# encoding: utf-8
require 'test_helper'

class NkfMemberTrialReminderTest < ActionMailer::TestCase
  def test_notify_overdue_trials
    NkfMemberTrialReminder.notify_overdue_trials
    assert_equal 1, Mail::TestMailer.deliveries.size
    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK][TEST] Utløpt prøvetid', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match %r{Følgende prøvemedlemmer har utløpt prøvetid:\s*<ul>\s*<li>\s*Hans Eriksen \(6 år\)\s*<ul>\s*<li>Registrert: 2010-10-03</li>\s*<li>1\s+treninger siste 2 måneder\s*</li>\s*<li>2 treninger totalt</li>\s*</ul>\s*</li>\s*<li>\s*Erik Hansen \(7 år\)\s*<ul>\s*<li>Registrert: 2010-10-03</li>\s*<li>0\s+treninger siste 2 måneder\s*</li>\s*<li>0 treninger totalt</li>\s*</ul>\s*</li>\s*</ul>}, mail.body.decoded
  end

  def test_send_waiting_lists
    NkfMemberTrialReminder.send_waiting_lists
    assert_equal 1, Mail::TestMailer.deliveries.size
    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK][TEST] Ventelister', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match "Følgende grupper har folk på venteliste:\r\n\r\n<ul>\r\n      <li>\r\n        Panda\r\n        <ul>\r\n          <li>Erik Hansen</li>\r\n        </ul>", mail.body.encoded
  end

end
