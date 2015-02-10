# encoding: utf-8
require 'test_helper'

class NkfMemberImportTest < ActionMailer::TestCase
  def test_import_members
    NkfMemberImport.import_nkf_changes

    assert_equal 3, Mail::TestMailer.deliveries.size

    mail = ActionMailer::Base.deliveries[0]
    assert_match /^Hentet \d{3} endringer fra NKF$/, mail.subject
    assert_equal 'uwe@kubosch.no', mail.header[:to].value
    assert_equal 'test@jujutsu.no', mail.header[:from].value
    assert_match "NKF Import\n\nEndringer fra NKF-portalen.\n", mail.body.decoded
    assert_match /\b\d{3} medlemmer opprettet\n\n/, mail.body.decoded
    assert_match "Endringer prøvetid:\n", mail.body.decoded
    assert_match "Nye medlemmer:\n    Sebastian Aagren:\n", mail.body.decoded

    mail = ActionMailer::Base.deliveries[1]
    assert_match /\[RJJK\]\[test\] Oppdateringer fra NKF: \d{3} nye, \d{3} gruppeendringer/,
        mail.subject
    assert_equal 'uwe@kubosch.no', mail.header[:to].value
    assert_equal 'test@jujutsu.no', mail.header[:from].value
    assert_match "Opprettet følgende nye medlemmer:\r\n\r\n    Abdorahman Lutf Muhammad\r\n",
        mail.body.encoded

    mail = ActionMailer::Base.deliveries[2]
    assert_equal '[RJJK][test] Verv fra NKF: 6', mail.subject
    assert_equal 'uwe@kubosch.no', mail.header[:to].value
    assert_equal 'test@jujutsu.no', mail.header[:from].value
    assert_match '<h3>Verv registrert i NKF registeret</h3>', mail.body.decoded
    assert_match "<td colspan=\"4\">Ukjent årsmøtedato: 16.02.2012 (Øyan Erik Leder)</td>",
        mail.body.decoded
    assert_match %r{<td>Svein Robert Rolijordet</td>\s*<td>Materialforvalter</td>\s*<td>2011-02-08</td>\s*<td>2014-03-31</td>},
        mail.body.decoded
    assert_match %r{<td>Curt Mekiassen</td>\s*<td>Foreldrerepresentant</td>\s*<td>2012-02-16</td>\s*<td>2014-03-31</td>},
        mail.body.decoded
    assert_match %r{<td>Asle Jåsund</td>\s*<td>Kasserer</td>\s*<td>2012-02-16</td>\s*<td>2014-03-31</td>},
        mail.body.decoded
    assert_match %r{<td>Uwe Kubosch</td>\s*<td>Hovedinstruktør</td>\s*<td>2013-01-01</td>\s*<td></td>},
        mail.body.decoded
    assert_match %r{<td>Tom Arild Knapkøien</td>\s*<td>Medlemsansvarlig</td>\s*<td>2014-02-25</td>\s*<td></td>},
        mail.body.decoded
  end
end
