# frozen_string_literal: true
require 'test_helper'

class GraduationReminderTest < ActionMailer::TestCase
  def test_notify_missing_graduations
    assert_mail_stored(1) { GraduationReminder.notify_missing_graduations }

    mail = UserMessage.pending[0]
    assert_equal ['"Uwe Kubosch" <admin@test.com>'], mail.to
    assert_equal 'Disse gruppene mangler gradering', mail.subject
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_match(/Hei Uwe.*Panda mangler gradering for dette semesteret/m, mail.body)
  end

  def test_notify_overdue_graduates
    graduations(:voksne_upcoming).destroy!
    ranks(:kyu_5).update! standard_months: 0

    assert_mail_stored(1) { GraduationReminder.notify_overdue_graduates }

    mail = UserMessage.pending[0]
    assert_equal ['"Uwe Kubosch" <admin@test.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Disse medlemmene mangler gradering', mail.subject
    assert_match(/Voksne.*Newbie Neuer.*5. kyu.*0.*1/m, mail.body)
  end

  def test_notify_groups
    assert_mail_stored(3) { GraduationReminder.notify_groups }

    mail = UserMessage.pending[0]
    assert_equal ['"Lars Bråten" <lars@example.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Gradering for Voksne 2013-10-24', mail.subject
    assert_match(/Hei Lars!/, mail.body)
    assert_match(/Gradering for Voksne er satt opp til 2013-10-24./, mail.body)
    assert_match(/Din nåværende registrerte grad hos oss er: 1. kyu brunt belte./, mail.body)
    assert_match(/Din neste grad er shodan svart belte./, mail.body)
    assert_match(
        /Minstekrav for denne graden er 84 treninger siden forrige gradering og at du har fylt 18 år./,
        mail.body
    )

    mail = UserMessage.pending[1]
    assert_equal ['"Uwe Kubosch" <admin@test.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Gradering for Voksne 2013-10-24', mail.subject
    assert_match(/Hei Uwe!/, mail.body)
    assert_match(/Gradering for Voksne er satt opp til 2013-10-24./, mail.body)
    assert_match(%r{Din nåværende registrerte grad hos oss er: nidan svart belte m/2 striper.},
        mail.body)
    assert_match(%r{Din neste grad er sandan svart belte m/3 striper.}, mail.body)
    assert_match(
        /Minstekrav for denne graden er 84 treninger siden forrige gradering og at du har fylt 22 år./,
        mail.body
    )

    mail = UserMessage.pending[2]
    assert_equal ['"Newbie Neuer" <newbie@example.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Gradering for Voksne 2013-10-24', mail.subject
    assert_match(/Hei Newbie!/, mail.body)
    assert_match(/Gradering for Voksne er satt opp til 2013-10-24./, mail.body)
    assert_match(/Vi har ikke registrert noen grad for deg fra før./,
        mail.body)
    assert_match(/Din neste grad er 5. kyu gult belte./, mail.body)
    assert_match(
        /Minstekrav for denne graden er 11 treninger siden du startet og at du har fylt 14 år./,
        mail.body
    )
  end

  def test_notify_censors
    assert_mail_stored(1) { GraduationReminder.notify_censors }

    mail = UserMessage.pending[0]
    assert_equal ['"Uwe Kubosch" <admin@test.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Invitasjon til å være eksminator', mail.subject
    assert_match(/Hei Uwe!/, mail.body)
    assert_match(
        /Jujutsu Klubb vil med dette invitere deg til å være\s+eksaminator\s+på\s+gradering for Voksne\s+den 2013-10-24./,
        mail.body
    )
    assert_match(/Har du mulighet til delta\?  Klikk på en av linkene nedenfor for å gi beskjed\n  om du kan eller ikke./,
        mail.body)
    assert_match(%r{<a href="http://example.com/censors/306982868/confirm">Jeg kommer :\)</a>}, mail.body)
    assert_match(%r{<a href="http://example.com/censors/306982868/decline">Beklager, jeg kommer ikke.</a>}, mail.body)
  end

  def test_notify_missing_locks
    censors(:uwe_voksne_upcoming).update! confirmed_at: 1.week.ago

    assert_mail_stored(1) { GraduationReminder.notify_missing_locks }

    mail = UserMessage.pending[0]
    assert_equal ['"Uwe Kubosch" <admin@test.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Bekrefte graderingsoppsett', mail.subject
    assert_match(%r{<h1>Hei Uwe Kubosch!</h1>}, mail.body)
    assert_match(/Det er på tide å legge inn kandidater på graderingen for Voksne 2013-10-24 og låse /, mail.body)
    assert_match(/oppsettet slik at kandidatene kan få påmindelse om gradering./, mail.body)
    assert_match(%r{Gå til <a href="http://example.com/graduations/812466982">graderingen</a>, legg inn }, mail.body)
    assert_match(/kandidatene, eksaminator og sensorer, og klikk så på "Klar til utsending"./, mail.body)
  end

  def test_notify_graduates
    assert_mail_stored(1) { GraduationReminder.notify_graduates }

    mail = UserMessage.pending[0]
    assert_equal ['"Newbie Neuer" <newbie@example.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Invitasjon til gradering', mail.subject
    assert_match(/Hei Newbie Neuer!/, mail.body)
    assert_match(/Du er satt opp til gradering torsdag 24. oktober/, mail.body)
    assert_match(/Har du mulighet til delta\?  Klikk på en av linkene nedenfor for å gi beskjed om du kan eller ikke./,
        mail.body)
    assert_match(%r{<a href="http://example.com/graduates/confirm/397971580">Jeg kommer :\)</a>}, mail.body)
    assert_match(%r{<a href="http://example.com/graduates/decline/397971580">Beklager, jeg kommer ikke.</a>}, mail.body)
    assert_match(/Minstekrav til gradering er 11 treninger. Vi har registrert 1 treninger på deg siden du startet./,
        mail.body)
    assert_match(/Du trenger altså 10 treninger til for å oppfylle kravet til gradering./, mail.body)
    assert_match(/Det er 2 treninger frem til graderingen./, mail.body)
  end

  def test_notify_missing_aprovals
    assert_mail_stored(3) { GraduationReminder.notify_missing_aprovals }

    mail = UserMessage.pending[0]
    assert_equal ['"Lars Bråten" <lars@example.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Bekrefte gradering', mail.subject
    assert_match(/Hei Lars!/, mail.body)
    assert_match(%r{<a href="http://example.com/graduations/658987981/edit">Tiger den 2007-10-09</a>}, mail.body)

    mail = UserMessage.pending[1]
    assert_equal ['"Uwe Kubosch" <admin@test.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Bekrefte gradering', mail.subject
    assert_match(/Hei Uwe!/, mail.body)
    assert_match(%r{<a href="http://example.com/graduations/84385526/edit">Panda den 2007-10-08</a>}, mail.body)

    mail = UserMessage.pending[2]
    assert_equal ['"Lars Bråten" <lars@example.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Bekrefte gradering', mail.subject
    assert_match(/Hei Lars!/, mail.body)
    assert_match(%r{<a href="http://example.com/graduations/84385526/edit">Panda den 2007-10-08</a>}, mail.body)
  end

  def test_send_shopping_list_not_locked
    assert_mail_stored(0) { GraduationReminder.send_shopping_list }
  end

  def test_send_shopping_list_locked
    censors(:uwe_voksne_upcoming).update! locked_at: Time.current

    assert_mail_stored(1) { GraduationReminder.send_shopping_list }

    mail = UserMessage.pending[0]
    assert_equal ['"Newbie Neuer" <newbie@example.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Liste over belter for gradering for Voksne 2013-10-24', mail.subject
    assert_match(/Hei Newbie!/, mail.body)
    assert_match(/Her er liste over belter for gradering for Voksne 2013-10-24./, mail.body)
    assert_match(/gult belte.*1/, mail.body)
  end

  def test_congratulate_graduates
    graduations(:voksne).update! held_on: 1.week.ago

    assert_mail_stored(2) { GraduationReminder.congratulate_graduates }

    mail = UserMessage.pending[0]
    assert_equal ['"Lars Bråten" <lars@example.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Gratulerer med bestått gradering!', mail.subject
    assert_match(/Vi har registrert din gradering 2013-10-10 til 1. kyu brunt belte./, mail.body)
    assert_match(
        /Neste grad for deg er shodan svart belte.  Frem til da kreves minst 84 treninger./,
        mail.body
    )

    mail = UserMessage.pending[1]
    assert_equal ['"Uwe Kubosch" <admin@test.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Gratulerer med bestått gradering!', mail.subject
    assert_match(%r{Vi har registrert din gradering 2013-10-10 til nidan svart belte m/2 striper.}, mail.body)
    assert_match(%r{Neste grad for deg er sandan svart belte m/3 striper.}, mail.body)
    assert_match(/Frem til da kreves minst 84 treninger./, mail.body)
  end
end
