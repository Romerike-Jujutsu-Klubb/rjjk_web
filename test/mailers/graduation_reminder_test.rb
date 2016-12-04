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
    assert_mail_stored(1) { GraduationReminder.notify_overdue_graduates }

    mail = UserMessage.pending[0]
    assert_equal ['"Uwe Kubosch" <admin@test.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Disse medlemmene mangler gradering', mail.subject
    assert_match(/Voksne.*Newbie Neuer.*5. kyu.*0.*1/m, mail.body)
  end

  def test_notify_groups
    assert_mail_stored(2) { GraduationReminder.notify_groups }

    mail = UserMessage.pending[0]
    assert_equal ['"Lars Bråten" <lars@example.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Gradering for Voksne 2007-10-10', mail.subject
    assert_match(/Hei Lars!/, mail.body)
    assert_match(/Gradering for Voksne er satt opp til 2007-10-10./, mail.body)
    assert_match(/Din nåværende registrerte grad hos oss er: 1. kyu brunt belte./, mail.body)
    assert_match(/Din neste grad er shodan svart belte./, mail.body)
    assert_match(
        /Minstekrav for denne graden er 84 treninger siden forrige gradering og at du har fylt 18 år./,
        mail.body
    )

    mail = UserMessage.pending[1]
    assert_equal ['"Uwe Kubosch" <admin@test.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Gradering for Voksne 2007-10-10', mail.subject
    assert_match(/Hei Uwe!/, mail.body)
    assert_match(/Gradering for Voksne er satt opp til 2007-10-10./, mail.body)
    assert_match(%r{Din nåværende registrerte grad hos oss er: nidan svart belte m/2 striper.},
        mail.body)
    assert_match(%r{Din neste grad er sandan svart belte m/3 striper.}, mail.body)
    assert_match(
        /Minstekrav for denne graden er 84 treninger siden forrige gradering og at du har fylt 22 år./,
        mail.body
    )
  end

  def test_notify_censors
    assert_mail_stored(1) { GraduationReminder.notify_censors }

    mail = UserMessage.pending[0]
    assert_equal ['"Lars Bråten" <lars@example.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Invitasjon til å være sensor', mail.subject
    assert_match(/Hei Lars!/, mail.body)
    assert_match(
        /Romerike Jujutsu Klubb vil med dette invitere deg til å være sensor på\s+gradering for Panda\s+den 2007-10-08./,
        mail.body
    )
    assert_match(/Har du mulighet til delta\?  Klikk på en av linkene nedenfor for å gi beskjed\n  om du kan eller ikke./,
        mail.body)
    assert_match(%r{<a href="http://example.com/censors/980190962/confirm">Jeg kommer :\)</a>}, mail.body)
    assert_match(%r{<a href="http://example.com/censors/980190962/decline">Beklager, jeg kommer ikke.</a>}, mail.body)
  end

  def test_notify_missing_locks
    assert_mail_stored(1) { GraduationReminder.notify_missing_locks }

    mail = UserMessage.pending[0]
    assert_equal ['"Lars Bråten" <lars@example.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Bekrefte graderingsoppsett', mail.subject
    assert_match(%r{<h1>Hei Lars Bråten!</h1>}, mail.body)
    assert_match(/Det er på tide å legge inn kandidater på graderingen for Panda 2007-10-08 og låse /, mail.body)
    assert_match(/oppsettet slik at kandidatene kan få påmindelse om gradering./, mail.body)
    assert_match(%r{Gå til <a href="http://example.com/graduations/84385526">graderingen</a>, legg inn }, mail.body)
    assert_match(/kandidatene, eksaminator og sensorer, og klikk så på "Klar til utsending"./, mail.body)
  end

  def test_notify_graduates
    assert_mail_stored(2) { GraduationReminder.notify_graduates }

    mail = UserMessage.pending[0]
    assert_equal ['"Lars Bråten" <lars@example.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Invitasjon til gradering', mail.subject
    assert_match(/Hei!/, mail.body)
    assert_match(/Du er satt opp til gradering onsdag 10. oktober/, mail.body)
    assert_match(/Har du mulighet til delta\?  Klikk på en av linkene nedenfor for å gi beskjed om du kan eller ikke./,
        mail.body)
    assert_match(%r{<a href="http://example.com/graduates/confirm/980190962">Jeg kommer :\)</a>}, mail.body)
    assert_match(%r{<a href="http://example.com/graduate/decline/980190962">Beklager, jeg kommer ikke.</a>}, mail.body)
    assert_match(/Krav til gradering er 84 treninger. Vi har registrert 4 treninger på deg siden du startet./, mail.body)
    assert_match(/Du trenger altså 80 treninger til for å oppfylle kravet til gradering./, mail.body)
    assert_match(/Det er -503 treninger frem til graderingen./, mail.body)

    mail = UserMessage.pending[1]
    assert_equal ['"Uwe Kubosch" <admin@test.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Invitasjon til gradering', mail.subject
    assert_match(/Hei!/, mail.body)
    assert_match(/Du er satt opp til gradering onsdag 10. oktober/, mail.body)
    assert_match(/Har du mulighet til delta\?  Klikk på en av linkene nedenfor for å gi beskjed om du kan eller ikke./,
        mail.body)
    assert_match(%r{<a href="http://example.com/graduates/confirm/669046589">Jeg kommer :\)</a>}, mail.body)
    assert_match(%r{<a href="http://example.com/graduate/decline/669046589">Beklager, jeg kommer ikke.</a>}, mail.body)
    assert_match(/Krav til gradering er 84 treninger. Vi har registrert 4 treninger på deg siden du startet. /, mail.body)
    assert_match(/Du trenger altså 80 treninger til for å oppfylle kravet til gradering./, mail.body)
    assert_match(/Det er -503 treninger frem til graderingen./, mail.body)
  end

  def test_notify_missing_aprovals
    assert_mail_stored(3) { GraduationReminder.notify_missing_aprovals }

    mail = UserMessage.pending[0]
    assert_equal ['"Lars Bråten" <lars@example.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Bekrefte gradering', mail.subject
    assert_match(/Hei Lars!/, mail.body)
    assert_match(%r{<a href="http://example.com/graduations/84385526/edit">Panda den 2007-10-08</a>}, mail.body)

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
    assert_match(%r{<a href="http://example.com/graduations/658987981/edit">Tiger den 2007-10-09</a>}, mail.body)
  end

  def test_send_shopping_list
    assert_mail_stored(1) { GraduationReminder.send_shopping_list }

    mail = UserMessage.pending[0]
    assert_equal ['"Newbie Neuer" <newbie@example.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Liste over belter for gradering for Voksne 2007-10-10', mail.subject
    assert_match(/Hei Newbie!/, mail.body)
    assert_match(/Her er liste over belter for gradering for Voksne 2007-10-10./, mail.body)
    assert_match(/brunt belte.*1.*svart belte.*1/m, mail.body)
  end

  def test_congratulate_graduates
    assert_mail_stored(2) { GraduationReminder.congratulate_graduates }

    mail = UserMessage.pending[0]
    assert_equal ['"Lars Bråten" <lars@example.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Gratulerer med bestått gradering!', mail.subject
    assert_match(/Vi har registrert din gradering 2007-10-10 til 1. kyu brunt belte./, mail.body)
    assert_match(
        /Neste grad for deg er shodan svart belte.  Frem til da kreves minst 84 treninger og at du har fylt 18 år./,
        mail.body
    )

    mail = UserMessage.pending[1]
    assert_equal ['"Uwe Kubosch" <admin@test.com>'], mail.to
    assert_equal %w(noreply@test.jujutsu.no), mail.from
    assert_equal 'Gratulerer med bestått gradering!', mail.subject
    assert_match(%r{Vi har registrert din gradering 2007-10-10 til nidan svart belte m/2 striper.}, mail.body)
    assert_match(%r{Neste grad for deg er sandan svart belte m/3 striper.}, mail.body)
    assert_match(/Frem til da kreves minst 84 treninger og at du har fylt 22 år./, mail.body)
  end
end
