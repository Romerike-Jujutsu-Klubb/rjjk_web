# frozen_string_literal: true

require 'test_helper'

class GraduationReminderTest < ActionMailer::TestCase
  def test_notify_missing_graduations
    assert_mail_stored { GraduationReminder.notify_missing_graduations }

    mail = UserMessage.pending[0]
    assert_equal ['uwe@example.com'], mail.to
    assert_equal 'Disse gruppene mangler gradering', mail.subject
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match(/Hei Uwe.*Panda mangler gradering for dette semesteret/m, mail.body)
    url = <<~URL.chomp
      https://example.com/graduations/new?graduation%5Bgroup_id%5D=84385526&amp;graduation%5Bgroup_notification%5D=true&amp;graduation%5Bheld_on%5D=2013-12-12
    URL
    assert_match(%(<a href="#{url}">Opprett gradering for Panda</a>), mail.body)
  end

  def test_notify_overdue_graduates_to_chief_instructor_role
    graduations(:voksne_upcoming).destroy!
    ranks(:kyu_5).update! standard_months: 0

    assert_mail_stored { GraduationReminder.notify_overdue_graduates }

    mail = UserMessage.pending[0]
    assert_equal ['uwe@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_equal 'Disse medlemmene mangler gradering', mail.subject
    assert_match(/Voksne.*Newbie Neuer.*5. kyu.*0.*1/m, mail.body)
  end

  def test_notify_overdue_graduates_to_chief_instructor_for_group
    graduations(:voksne_upcoming).destroy!
    ranks(:kyu_5).update! standard_months: 0
    GroupSemester.create! group_id: id(:voksne), semester_id: id(:next), first_session: '2014-01-09',
        last_session: '2014-06-14', chief_instructor_id: id(:lars)

    assert_mail_stored { GraduationReminder.notify_overdue_graduates }

    mail = UserMessage.pending[0]
    assert_equal ['lars@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_equal 'Disse medlemmene mangler gradering', mail.subject
    assert_match(/Voksne.*Newbie Neuer.*5. kyu.*0.*1/m, mail.body)
  end

  def test_notify_missing_censors
    censors(:uwe_voksne_upcoming).update! examiner: false
    assert_mail_stored { GraduationReminder.notify_missing_censors }

    mail = UserMessage.pending[0]
    assert_equal ['uwe@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_equal 'Denne graderingen mangler eksaminator', mail.subject
    assert_match(/Hei Uwe!/, mail.body)
    assert_match(/Kan du gå inn på RJJK webben og legge til eksaminator på graderingen for/, mail.body)
    assert_match('Voksne den 2013-10-24', mail.body)
  end

  def test_notify_groups
    assert_mail_stored(3) { GraduationReminder.notify_groups }

    mail = UserMessage.pending[0]
    assert_equal ['lars@example.com'], mail.to
    assert_equal %w[uwe@example.com], mail.from
    assert_equal 'Gradering for Voksne 2013-10-24', mail.subject
    assert_match(/Hei Lars!/, mail.body)
    assert_match('Felles gradering for Voksne er satt opp til <b>2013-10-24</b>.', mail.body)
    assert_match(%r{Din nåværende registrerte grad hos oss er <b>1. kyu brunt belte</b>.}, mail.body)
    assert_match(%r{Din neste grad er <b>shodan svart belte</b>.}, mail.body)

    mail = UserMessage.pending[1]
    assert_equal ['neuer@example.com', 'newbie@example.com'], mail.to
    assert_equal %w[uwe@example.com], mail.from
    assert_equal 'Gradering for Voksne 2013-10-24', mail.subject
    assert_match(/Hei Newbie!/, mail.body)
    assert_match('Felles gradering for Voksne er satt opp til <b>2013-10-24</b>.', mail.body)
    assert_match(/Vi har ikke registrert noen grad for deg fra før./,
        mail.body)
    assert_match(%r{Din neste grad er <b>5. kyu gult belte</b>.}, mail.body)

    mail = UserMessage.pending[2]
    assert_equal ['uwe@example.com'], mail.to
    assert_equal %w[uwe@example.com], mail.from
    assert_equal 'Gradering for Voksne 2013-10-24', mail.subject
    assert_match(/Hei Uwe!/, mail.body)
    assert_match('Felles gradering for Voksne er satt opp til <b>2013-10-24</b>.', mail.body)
    assert_match(%r{Din nåværende registrerte grad hos oss er <b>nidan svart belte m/2 striper</b>.},
        mail.body)
    assert_match(%r{Din neste grad er <b>sandan svart belte m/3 striper</b>.}, mail.body)
  end

  def test_notify_censors
    assert_mail_stored { GraduationReminder.notify_censors }

    mail = UserMessage.pending[0]
    assert_equal ['uwe@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_equal 'Invitasjon til å være eksaminator', mail.subject
    assert_match(/Hei Uwe!/, mail.body)
    assert_match(
        /Jujutsu Klubb vil med dette invitere deg til å være\s+eksaminator\s+på\s+gradering for Voksne\s+den 2013-10-24./, # rubocop: disable Metrics/LineLength
        mail.body
      )
    assert_match(/Har du mulighet til delta\?  Klikk på en av linkene nedenfor for å gi beskjed\r\n  om du kan eller ikke./, # rubocop: disable Metrics/LineLength
        mail.body)
    assert_match(%r{<a href="https://example.com/censors/306982868/confirm">Jeg kommer :\)</a>}, mail.body)
    assert_match(%r{<a href="https://example.com/censors/306982868/decline">Beklager, jeg kommer ikke.</a>},
        mail.body)
  end

  def test_notify_missing_locks
    censors(:uwe_voksne_upcoming).update! confirmed_at: 1.week.ago

    assert_mail_stored { GraduationReminder.notify_missing_locks }

    mail = UserMessage.pending[0]
    assert_equal ['uwe@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_equal 'Bekrefte graderingsoppsett', mail.subject
    assert_match(%r{<h1>Hei Uwe Kubosch!</h1>}, mail.body)
    assert_match(/Det er på tide å legge inn kandidater på graderingen for Voksne 2013-10-24 og låse /, mail.body)
    assert_match(/oppsettet slik at kandidatene kan få innkalling til gradering./, mail.body)
    assert_match(%r{Gå til <a href="https://example.com/graduations/812466982/edit">graderingen</a>, legg inn },
        mail.body)
    assert_match(/kandidatene, eksaminator og sensorer, og klikk så på "Send innkalling"./, mail.body)
  end

  def test_notify_graduates_skip_unless_examiner_approved_graduates
    assert_mail_stored(0) { GraduationReminder.invite_graduates }
  end

  def test_notify_graduates
    censors(:uwe_voksne_upcoming).update! locked_at: Time.current

    assert_mail_stored(2) { GraduationReminder.invite_graduates }

    mail = UserMessage.pending[1]
    assert_equal ['neuer@example.com', 'newbie@example.com'], mail.to
    assert_equal %w[uwe@example.com], mail.from
    assert_equal 'Invitasjon til gradering', mail.subject
    assert_match(/Hei Newbie Neuer!/, mail.body)
    assert_match(/Du er satt opp til gradering torsdag 24. oktober/, mail.body)
    assert_match(
        /Har du mulighet til delta\? {2}Klikk på en av linkene nedenfor for å gi beskjed om du kan eller ikke./,
        mail.body
      )
    assert_match(%r{<a href="https://example.com/graduates/397971580/confirm">Jeg kommer :\)</a>}, mail.body)
    assert_match(%r{<a href="https://example.com/graduates/397971580/decline">Beklager, jeg kommer ikke.</a>},
        mail.body)
    assert_match(/Krav til gradering er 10-20 treninger. Vi har registrert 1 trening på deg siden du startet./,
        mail.body)

    mail = UserMessage.pending[0]
    assert_equal ['sebastian@example.com', 'uwe@example.com'], mail.to
    assert_equal %w[uwe@example.com], mail.from
    assert_equal 'Invitasjon til gradering', mail.subject
    assert_match(/Hei Sebastian Kubosch!/, mail.body)
    assert_match(/Du er satt opp til gradering torsdag 24. oktober/, mail.body)
    assert_match(
        /Har du mulighet til delta\? {2}Klikk på en av linkene nedenfor for å gi beskjed om du kan eller ikke./,
        mail.body
      )
    seb_id = id :sebastian_kyu_5
    assert_match(%r{<a href="https://example.com/graduates/#{seb_id}/confirm">Jeg kommer :\)</a>}, mail.body)
    assert_match(%r{<a href="https://example.com/graduates/#{seb_id}/decline">Beklager, jeg kommer ikke.</a>},
        mail.body)
    assert_match(
        /Krav til gradering er 10-20 treninger. Vi har registrert 0 treninger på deg siden gradering 2007-10-08./,
        mail.body
      )
  end

  def test_notify_missing_approvals
    assert_mail_stored(2) { GraduationReminder.notify_missing_approvals }

    mail = UserMessage.pending[0]
    assert_equal ['lars@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_equal 'Bekrefte gradering', mail.subject
    assert_match(/Hei Lars!/, mail.body)
    assert_match(%r{<a href="https://example.com/graduations/658987981/edit">Tiger den 2007-10-09</a>}, mail.body)

    mail = UserMessage.pending[1]
    assert_equal ['uwe@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_equal 'Bekrefte gradering', mail.subject
    assert_match(/Hei Uwe!/, mail.body)
    assert_match(%r{<a href="https://example.com/graduations/84385526/edit">Panda den 2007-10-08</a>}, mail.body)

    censors(:lars_tiger).update! approved_grades_at: Time.current
    censors(:uwe_panda).update! approved_grades_at: Time.current
    assert_mail_stored(initial: 2) { GraduationReminder.notify_missing_approvals }

    mail = UserMessage.pending[2]
    assert_equal ['lars@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_equal 'Bekrefte gradering', mail.subject
    assert_match(/Hei Lars!/, mail.body)
    assert_match(%r{<a href="https://example.com/graduations/84385526/edit">Panda den 2007-10-08</a>}, mail.body)
  end

  def test_notify_missing_approvals_with_unconfirmed_censors
    Censor.update_all confirmed_at: nil, declined: nil # rubocop:disable Rails/SkipsModelValidations
    assert_mail_stored(2) { GraduationReminder.notify_missing_approvals }
    assert_equal 'lars@example.com', UserMessage.pending[0].user.email
    assert_equal 'uwe@example.com', UserMessage.pending[1].user.email
    censors(:lars_tiger).update! approved_grades_at: Time.current
    censors(:uwe_panda).update! approved_grades_at: Time.current
    assert_mail_stored(initial: 2) { GraduationReminder.notify_missing_approvals }
    assert_equal 'lars@example.com', UserMessage.pending[0].user.email
  end

  def test_send_shopping_list_not_locked
    assert_mail_stored(0) { GraduationReminder.send_shopping_list }
  end

  def test_send_shopping_list_locked
    censors(:uwe_voksne_upcoming).update! locked_at: 2.days.ago

    assert_mail_stored { GraduationReminder.send_shopping_list }

    mail = UserMessage.pending[0]
    assert_equal ['oldie@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_equal 'Liste over belter for gradering for Voksne 2013-10-24', mail.subject
    assert_match(/Hei Oldie!/, mail.body)
    assert_match(/Her er liste over belter for gradering for Voksne 2013-10-24./, mail.body)
    assert_match(/gult belte.*2/, mail.body)
  end

  def test_congratulate_graduates
    graduations(:voksne).update! held_on: 1.week.ago
    ranks(:shodan).update! standard_months: 0

    assert_mail_stored(2) { GraduationReminder.congratulate_graduates }

    mail = UserMessage.pending[0]
    assert_equal ['lars@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_equal 'Gratulerer med bestått gradering!', mail.subject
    assert_match('Vi har registrert din gradering 2013-10-10 til 1. kyu brunt belte.', mail.body)
    assert_match(
        'Neste grad for deg er shodan svart belte.  Frem til da kreves 0-0 treninger.', mail.body
      )
    assert_match('Vi har registrert 0 treninger på deg siden forrige gradering.', mail.body)

    mail = UserMessage.pending[1]
    assert_equal ['uwe@example.com'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_equal 'Gratulerer med bestått gradering!', mail.subject
    assert_match(%r{Vi har registrert din gradering 2013-10-10 til nidan svart belte m/2 striper.}, mail.body)
    assert_match(%r{Neste grad for deg er sandan svart belte m/3 striper.}, mail.body)
    assert_match(/Frem til da kreves 80-160 treninger./, mail.body)
  end

  def test_congratulate_graduates_no_censors
    graduations(:voksne).update! held_on: 1.week.ago
    Censor.delete_all
    assert_mail_stored(2) { GraduationReminder.congratulate_graduates }
  end

  def test_congratulate_graduates_unconfirmed_censors
    g = graduations(:voksne)
    g.update! held_on: 1.week.ago
    g.censors.create! member: members(:newbie), examiner: true
    Censor.update_all confirmed_at: nil, approved_grades_at: nil # rubocop:disable Rails/SkipsModelValidations
    assert_mail_stored(0) { GraduationReminder.congratulate_graduates }
  end

  def test_congratulate_graduates_censors_not_approved
    g = graduations(:voksne)
    g.update! held_on: 1.week.ago
    g.censors.create! member: members(:newbie), examiner: true
    Censor.update_all confirmed_at: 3.weeks.ago, approved_grades_at: nil # rubocop:disable Rails/SkipsModelValidations
    assert_mail_stored(0) { GraduationReminder.congratulate_graduates }
  end

  def test_congratulate_graduates_censors_approved
    g = graduations(:voksne)
    g.update! held_on: 1.week.ago
    g.censors.create! member: members(:newbie), examiner: true
    Censor.update_all confirmed_at: 3.weeks.ago, approved_grades_at: 2.days.ago # rubocop:disable Rails/SkipsModelValidations
    assert_mail_stored(2) { GraduationReminder.congratulate_graduates }
  end
end
