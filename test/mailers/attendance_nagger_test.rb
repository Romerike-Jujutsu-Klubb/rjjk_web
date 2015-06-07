# encoding: utf-8
require 'test_helper'

class AttendanceNaggerTest < ActionMailer::TestCase
  def test_send_attendance_plan
    AttendanceNagger.send_attendance_plan
    assert_equal 2, Mail::TestMailer.deliveries.size

    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK][TEST] Kommer du?', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match "Følg linken til\r\n    <a href=\"http://example.com/mitt/oppmote?key=random_token_string+++++++++++++++++++++\">Mitt oppmøte</a>", mail.body.encoded

    mail = ActionMailer::Base.deliveries[1]
    assert_equal '[RJJK][TEST] Kommer du?', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match %r{Følg linken til\s*<a href="http://example.com/mitt/oppmote\?key=[0-9a-f]{40}">Mitt oppmøte</a>},
        mail.body.encoded
  end

  def test_send_message_reminder_same_day
    AttendanceNagger.send_message_reminder
    assert_mail_deliveries 0
  end

  def test_send_message_reminder_day_before
    Timecop.freeze(Time.local 2013, 10, 16, 18, 46, 0) do
      assert_mail_deliveries(2) { AttendanceNagger.send_message_reminder }

      mail = ActionMailer::Base.deliveries[0]
      assert_equal '[RJJK][TEST] Tema for morgendagens trening for Panda',
          mail.subject
      assert_equal %w(uwe@kubosch.no), mail.to
      assert_equal %w(test@jujutsu.no), mail.from
      assert_match 'Har du en melding til de som skal trene i morgen?',
          mail.body.encoded

      mail = ActionMailer::Base.deliveries[1]
      assert_equal '[RJJK][TEST] Tema for morgendagens trening for Panda',
          mail.subject
      assert_equal %w(uwe@kubosch.no), mail.to
      assert_equal %w(test@jujutsu.no), mail.from
      assert_match 'Har du en melding til de som skal trene i morgen?',
          mail.body.encoded
    end
  end

  def test_send_attendance_summary
    assert_mail_deliveries(3) { AttendanceNagger.send_attendance_summary }

    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK][TEST] Trening i kveld: 1 deltaker påmeldt',
        mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match "<ul>\r\n      <li>Uwe Kubosch</li>\r\n</ul>",
        mail.body.encoded

    mail = ActionMailer::Base.deliveries[1]
    assert_equal '[RJJK][TEST] Trening i kveld: 1 deltaker påmeldt',
        mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match "<ul>\r\n      <li>Uwe Kubosch</li>\r\n</ul>",
        mail.body.encoded

    mail = ActionMailer::Base.deliveries[2]
    assert_equal '[RJJK][TEST] Trening i kveld: 1 deltaker påmeldt',
        mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match "<ul>\r\n      <li>Uwe Kubosch</li>\r\n</ul>",
        mail.body.encoded
  end

  def test_send_attendance_changes
    assert_mail_deliveries(3) { AttendanceNagger.send_attendance_changes }

    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK][TEST] Trening i kveld: 1 ny deltaker påmeldt', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match "Nylig påmeldt</h3>\r\n\r\n    <ul>\r\n          <li>Uwe Kubosch</li>", mail.body.encoded

    mail = ActionMailer::Base.deliveries[1]
    assert_equal '[RJJK][TEST] Trening i kveld: 1 ny deltaker påmeldt', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match "Nylig påmeldt</h3>\r\n\r\n    <ul>\r\n          <li>Uwe Kubosch</li>", mail.body.encoded

    mail = ActionMailer::Base.deliveries[2]
    assert_equal '[RJJK][TEST] Trening i kveld: 1 ny deltaker påmeldt', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match "Nylig påmeldt</h3>\r\n\r\n    <ul>\r\n          <li>Uwe Kubosch</li>", mail.body.encoded
  end

  def test_send_attendance_review
    AttendanceNagger.send_attendance_review
    assert_equal 1, Mail::TestMailer.deliveries.size
    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK][TEST] Hvordan var treningen?', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match %r{17:45-18:45\s+Panda.*[<a href="http://example.com/attendances/review/2013/42/84385526/X?key=.{40}">Var der!</a>]}m, mail.body.encoded
  end
end
