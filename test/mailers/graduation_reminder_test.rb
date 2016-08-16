require 'test_helper'

class GraduationReminderTest < ActionMailer::TestCase
  def test_notify_missing_graduations
    assert_mail_stored(1) { GraduationReminder.notify_missing_graduations }

    mail = UserMessage.pending[0]
    assert_equal ["\"Uwe Kubosch\" <admin@test.com>"], mail.to
    assert_equal 'Disse gruppene mangler gradering', mail.subject
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_match(/Hei Uwe.*Panda mangler gradering for dette semesteret/m,
        mail.body)
  end

  def test_notify_overdue_graduates
    assert_mail_stored(1) { GraduationReminder.notify_overdue_graduates }

    mail = UserMessage.pending[0]
    assert_equal ["\"Uwe Kubosch\" <admin@test.com>"], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Disse medlemmene mangler gradering', mail.subject
    assert_match(/Voksne.*Newbie Neuer.*5. kyu.*0.*1/m, mail.body)
  end
end
