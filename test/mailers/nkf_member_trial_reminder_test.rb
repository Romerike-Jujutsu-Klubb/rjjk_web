# frozen_string_literal: true
require 'test_helper'

class NkfMemberTrialReminderTest < ActionMailer::TestCase
  def test_notify_overdue_trials
    assert_mail_stored(1) { NkfMemberTrialReminder.notify_overdue_trials }

    mail = UserMessage.pending[0]
    assert_equal 'Utløpt prøvetid', mail.subject
    assert_equal ['"Uwe Kubosch" <admin@test.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_match %r{Følgende prøvemedlemmer har utløpt prøvetid:\s*<ul>\s*<li>\s*Hans Eriksen \(6 år\)\s*<ul>\s*<li>Registrert: 2010-10-03</li>\s*<li>1\s+treninger siste 2 måneder\s*</li>\s*<li>2 treninger totalt</li>\s*</ul>\s*</li>\s*<li>\s*Erik Hansen \(7 år\)\s*<ul>\s*<li>Registrert: 2010-10-03</li>\s*<li>0\s+treninger siste 2 måneder\s*</li>\s*<li>0 treninger totalt</li>\s*</ul>\s*</li>\s*</ul>},
        mail.body
  end
end
