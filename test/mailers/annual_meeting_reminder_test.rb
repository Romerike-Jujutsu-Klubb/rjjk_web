require 'test_helper'

class AnnualMeetingReminderTest < ActionMailer::TestCase
  def test_notify_missing_date_not_sent_if_present
    assert_equal 0, Mail::TestMailer.deliveries.size
    AnnualMeetingReminder.notify_missing_date
    assert_equal 0, Mail::TestMailer.deliveries.size
  end

  def test_notify_missing_date
    annual_meetings(:two).destroy
    assert_mail_stored(1) { AnnualMeetingReminder.notify_missing_date }

    mail = UserMessage.pending[0]
    assert_equal '[RJJK][TEST] På tide å sette dato for årsmøte 2014', mail.subject
    assert_equal ["\"Uwe Kubosch\" <admin@test.com>"], mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match '<title>På tide å sette dato for årsmøte 2014</title>', mail.body
    assert_match 'På tide å sette dato for årsmøte 2014', mail.body
    assert_match '<h1>Hei Uwe !</h1>', mail.body
    assert_match "Det er på tide å sette opp dato for årsmøtet 2014. For å registrere datoen\n  kan du gå inn på linken under.",
        mail.body
    assert_match %r{<a href="http://example.com/annual_meetings/new\?key=[0-9a-f]{40}">Årsmøte 2014</a>},
        mail.body
    assert_match 'Årsmøtet skal holdes i februar.', mail.body
  end

  def test_notify_missing_invitation_not_sent_if_in_far_future
    AnnualMeetingReminder.notify_missing_invitation
    assert_equal 0, Mail::TestMailer.deliveries.size
  end

  def test_notify_missing_invitation
    Timecop.freeze(Time.parse('2014-01-21 13:37')) do
      AnnualMeetingReminder.notify_missing_invitation
      assert_equal 1, UserMessage.pending.size

      mail = UserMessage.pending[0]
      assert_equal '[RJJK][TEST] På tide å sende ut innkalling til årsmøte 2014', mail.subject
      assert_equal ["\"Lars Bråten\" <lars@example.com>"], mail.to
      assert_equal %w(test@jujutsu.no), mail.from
      assert_match "", mail.body
      assert_match "", mail.body
    end
  end
end
