# frozen_string_literal: true

require 'test_helper'

class NkfMemberTrialReminderTest < ActionMailer::TestCase
  def test_notify_overdue_trials
    assert_mail_stored(2) { NkfMemberTrialReminder.notify_overdue_trials }

    mail = UserMessage.pending[0]
    assert_equal 'Utløpt prøvetid', mail.subject
    assert_equal ['lise@example.com', 'sebastian@example.com', 'uwe@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match %r{Følgende prøvemedlemmer har utløpt prøvetid:<ul><li><a href="https://example.com/signups/113629430">Even Jensen</a> \(6 år\)<ul><li>Registrert: 2010-10-02</li><li>0 treninger siste 2 måneder</li><li>0 treninger totalt</li></ul></li></ul>}, # rubocop: disable Layout/LineLength
        mail.body

    mail = UserMessage.pending[1]
    assert_equal 'Utløpt prøvetid', mail.subject
    assert_equal ['uwe@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match %r{Følgende prøvemedlemmer har utløpt prøvetid:<ul><li><a href="https://example.com/signups/980190962">Hans Eriksen</a> \(6 år\)<ul><li>Registrert: 2010-10-03</li><li>1 treninger siste 2 måneder</li><li>2 treninger totalt</li></ul></li><li><a href="https://example.com/signups/298486374">Erik Hansen</a> \(7 år\)<ul><li>Registrert: 2010-10-03</li><li>0 treninger siste 2 måneder</li><li>0 treninger totalt</li></ul></li></ul>}, # rubocop: disable Layout/LineLength
        mail.body
  end
end
