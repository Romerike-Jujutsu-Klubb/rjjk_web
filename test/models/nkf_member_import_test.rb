# frozen_string_literal: true
require 'test_helper'

class NkfMemberImportTest < ActionMailer::TestCase
  def test_import_members
    VCR.use_cassette('NKF Import Changes', match_requests_on: [:method, :host, :path, :query],
        allow_playback_repeats: true) do
      assert_mail_deliveries(3) { NkfMemberImport.import_nkf_changes }
    end

    mail = ActionMailer::Base.deliveries[0]
    assert_match(/^Hentet \d{3} endringer fra NKF$/, mail.subject, mail.body.decoded)
    assert_equal 'uwe@kubosch.no', mail.header[:to].value
    assert_equal 'noreply@test.jujutsu.no', mail.header[:from].value
    assert_match "NKF Import\n\nEndringer fra NKF-portalen.\n", mail.body.decoded
    assert_match(/\b\d{3} medlemmer opprettet\n\n/, mail.body.decoded)
    assert_match "Endringer prøvetid:\n", mail.body.decoded
    assert_match "Nye medlemmer:\n    Sebastian Aagren:\n", mail.body.decoded

    mail = ActionMailer::Base.deliveries[1]
    assert_match(/Oppdateringer fra NKF: \d{3} nye, 1 endrede, \d{3} gruppeendringer/, mail.subject)
    assert_equal 'uwe@kubosch.no', mail.header[:to].value
    assert_equal 'noreply@test.jujutsu.no', mail.header[:from].value
    assert_match "Opprettet følgende nye medlemmer:\r\n\r\n    Abdorahman Lutf Muhammad\r\n",
        mail.body.encoded

    mail = ActionMailer::Base.deliveries[2]
    assert_equal 'Verv fra NKF: 7', mail.subject
    assert_equal 'uwe@kubosch.no', mail.header[:to].value
    assert_equal 'noreply@test.jujutsu.no', mail.header[:from].value
    assert_match '<h3>Verv registrert i NKF registeret</h3>', mail.body.decoded
    assert_match %r{
          <td>Uwe\ Kubosch</td>\s*
          <td>Hovedinstruktør</td>\s*
          <td>2013-01-01</td>\s*
          <td></td>
        }x,
        mail.body.decoded
    assert_match %r{
          <td>Svein\ Robert\ Rolijordet</td>\s*
          <td>Leder\ \(2\ år\)</td>\s*
          <td>2014-02-25</td>\s*
          <td></td>
        }x,
        mail.body.decoded
    assert_match %r{
          <td>Bastian\ Filip\ Krohn</td>\s*
          <td>Kasserer</td>\s*
          <td>2015-02-12</td>\s*
          <td></td>
        }x,
        mail.body.decoded
  end
end
