require 'test_helper'

class AttendanceNaggerTest < ActionMailer::TestCase
  def test_send_attendance_plan
    AttendanceNagger.send_attendance_plan
    assert_equal 1, Mail::TestMailer.deliveries.size
    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK] Kommer du?', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match "Følg linken til\r\n    <a href=\"http://example.com/mitt/oppmote?key=random_token_string+++++++++++++++++++++\">Mitt oppmøte</a>", mail.body.encoded
  end

  def test_send_message_reminder
    AttendanceNagger.send_message_reminder
    assert_equal 0, Mail::TestMailer.deliveries.size
  end

  def test_send_attendance_summary
    AttendanceNagger.send_attendance_summary
    assert_equal 2, Mail::TestMailer.deliveries.size
    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK] Trening i kveld: 1 deltaker påmeldt', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match "<ul>\r\n      <li>Uwe Kubosch</li>\r\n</ul>", mail.body.encoded

    mail = ActionMailer::Base.deliveries[1]
    assert_equal '[RJJK] Trening i kveld: 1 deltaker påmeldt', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match "<ul>\r\n      <li>Uwe Kubosch</li>\r\n</ul>", mail.body.encoded
  end

  def test_send_attendance_changes
    AttendanceNagger.send_attendance_changes
    assert_equal 2, Mail::TestMailer.deliveries.size
    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK] Trening i kveld: 1 ny deltaker påmeldt', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match "Nylig påmeldt</h3>\r\n\r\n    <ul>\r\n          <li>Uwe Kubosch</li>", mail.body.encoded

    mail = ActionMailer::Base.deliveries[1]
    assert_equal '[RJJK] Trening i kveld: 1 ny deltaker påmeldt', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match "Nylig påmeldt</h3>\r\n\r\n    <ul>\r\n          <li>Uwe Kubosch</li>", mail.body.encoded
  end

  def test_send_attendance_review
    AttendanceNagger.send_attendance_review
    assert_equal 1, Mail::TestMailer.deliveries.size
    mail = ActionMailer::Base.deliveries[0]
    assert_equal '[RJJK] Hvordan var treningen?', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match %r{17:45-18:45\s+Panda.*[<a href="http://example.com/attendances/review/2013/42/84385526/X?key=.{40}">Var der!</a>]}m, mail.body.encoded
  end
end
