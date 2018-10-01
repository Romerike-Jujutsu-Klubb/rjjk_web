# frozen_string_literal: true

require 'test_helper'

class AttendanceNaggerTest < ActionMailer::TestCase
  def test_send_attendance_plan
    assert_mail_stored(2) { AttendanceNagger.send_attendance_plan }

    mail = UserMessage.pending[0]
    assert_equal 'Kommer du?', mail.subject
    assert_equal ['lars@example.com'],
        mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match %r{Følg linken til\s+<a href="https://example.com/mitt/oppmote">Mitt oppmøte</a>},
        mail.body

    mail = UserMessage.pending[1]
    assert_equal 'Kommer du?', mail.subject
    assert_equal ['newbie@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match %r{Følg linken til\s*<a href="https://example.com/mitt/oppmote">Mitt oppmøte</a>},
        mail.body
  end

  def test_send_message_reminder_same_day
    AttendanceNagger.send_message_reminder
    assert_mail_deliveries 0
  end

  def test_send_message_reminder_day_before
    groups(:panda).update! planning: true # Cleanup test fixtures
    Timecop.freeze(Time.zone.local(2013, 10, 16, 18, 46, 0)) do
      assert_mail_stored { AttendanceNagger.send_message_reminder }

      mail = UserMessage.pending[0]
      assert_equal 'Tema for morgendagens trening for Panda',
          mail.subject
      assert_equal ['uwe@example.com'], mail.to
      assert_equal %w[noreply@test.jujutsu.no], mail.from
      assert_match 'Har du en melding til de som skal trene i morgen?', mail.body
    end
  end

  def test_send_attendance_summary
    assert_mail_stored(3) { AttendanceNagger.send_attendance_summary }

    mail = UserMessage.pending[0]
    assert_equal 'Trening i kveld: 1 deltaker påmeldt', mail.subject
    assert_equal ['uwe@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match '<ul><li>Uwe Kubosch</li></ul>', mail.html_body

    mail = UserMessage.pending[1]
    assert_equal 'Trening i kveld: 1 deltaker påmeldt', mail.subject
    assert_equal ['lars@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match '<ul><li>Uwe Kubosch</li></ul>', mail.html_body

    mail = UserMessage.pending[2]
    assert_equal 'Trening i kveld: 1 deltaker påmeldt', mail.subject
    assert_equal ['newbie@example.com'], mail.to
    assert_equal ['noreply@test.jujutsu.no'], mail.from
    assert_match '<ul><li>Uwe Kubosch</li></ul>', mail.html_body
  end

  def test_send_attendance_changes
    assert_mail_stored(3) { AttendanceNagger.send_attendance_changes }

    mail = UserMessage.pending[0]
    assert_equal 'Trening i kveld: 1 ny deltaker påmeldt', mail.subject
    assert_equal ['uwe@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match 'Nylig påmeldt</h3><ul><li>Uwe Kubosch</li>', mail.body

    mail = UserMessage.pending[1]
    assert_equal 'Trening i kveld: 1 ny deltaker påmeldt', mail.subject
    assert_equal ['lars@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match 'Nylig påmeldt</h3><ul><li>Uwe Kubosch</li>', mail.body

    mail = UserMessage.pending[2]
    assert_equal 'Trening i kveld: 1 ny deltaker påmeldt', mail.subject
    assert_equal ['newbie@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match 'Nylig påmeldt</h3><ul><li>Uwe Kubosch</li>', mail.body
  end

  def test_send_attendance_review
    groups(:panda).update! planning: true # Cleanup test fixtures
    AttendanceNagger.send_attendance_review
    assert_equal 1, UserMessage.pending.size
    mail = UserMessage.pending[0]
    assert_equal 'Hvordan var treningen?', mail.subject
    assert_equal ['uwe@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match %r{17:45-18:45\s+Panda.*
            \[<a\ href="https://example.com/attendances/review/2013/42/84385526/X
            \?key=.{40}">Trente!</a>\]
        }mx,
        mail.body
  end
end
