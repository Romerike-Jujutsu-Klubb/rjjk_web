# encoding: utf-8
require 'test_helper'

class GraduationReminderTest < ActionMailer::TestCase
  def test_notify_missing_graduations
    GraduationReminder.notify_missing_graduations

    assert_equal 1, Mail::TestMailer.deliveries.size
    mail = Mail::TestMailer.deliveries[0]
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal '[RJJK][test] Disse gruppene mangler gradering', mail.subject
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match /Hei Uwe.*Panda mangler gradering for dette semesteret/m, mail.encoded
  end

  def test_notify_overdue_graduates
    GraduationReminder.notify_overdue_graduates

    assert_equal 1, Mail::TestMailer.deliveries.size
    mail = Mail::TestMailer.deliveries[0]
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_equal '[RJJK][test] Disse medlemmene mangler gradering', mail.subject
    assert_match /Voksne.*Newbie Neuer.*5. kyu.*0.*0/m, mail.decoded
  end
end
