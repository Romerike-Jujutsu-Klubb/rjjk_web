# frozen_string_literal: true

require 'test_helper'

class NkfMemberImportTest < ActionMailer::TestCase
  def test_import_members
    AnnualMeeting.create! start_at: '2015-02-12 17:45'
    assert_mail_deliveries(3) do
      VCR.use_cassette('NKF Import Changes', match_requests_on: %i[method host path query body],
                                             allow_playback_repeats: true) do
        NkfMemberImport.import_nkf_changes
      end
    end

    mail = ActionMailer::Base.deliveries[0]
    assert_match(/^Hentet \d{3} endringer fra NKF$/, mail.subject, mail.body.decoded)
    assert_equal 'uwe@kubosch.no', mail.header[:to].value
    assert_equal 'noreply@test.jujutsu.no', mail.header[:from].value
    assert_match "NKF Import\n\nEndringer fra NKF-portalen.\n", mail.body.decoded
    assert_match(/\b\d{3} medlemmer opprettet\n3 medlemmer oppdatert\n/, mail.body.decoded)
    assert_match "Endringer prøvetid:\n", mail.body.decoded
    assert_match "Nye medlemmer:\n    Sebastian Aagren:\n", mail.body.decoded

    mail = ActionMailer::Base.deliveries[1]
    assert_match(/Oppdateringer fra NKF: \d{3} nye, 3 endrede/, mail.subject)
    assert_equal 'uwe@kubosch.no', mail.header[:to].value
    assert_equal 'noreply@test.jujutsu.no', mail.header[:from].value
    assert_match "Opprettet følgende nye medlemmer:\n\n    Abdorahman Lutf Muhammad\n",
        mail.body.decoded
    changes = <<~EOF
      Oppdaterte følgende eksisterende medlemmer:

          Lars Erling Bråten
              first_name: "Lars" => "Lars Erling"
              address: ".+" => ""
              birthdate: Wed, 21 Jun 1967 => .+
              phone_home: nil => "\\d{8}"
              phone_work: nil => "\\d{8}"
              phone_mobile: nil => "\\d{8}"
              email: "lars@example.com" => ".+"
              billing_email: nil => ".+"
              joined_on: Thu, 21 Jun 2007 => Tue, 14 Oct 2003
          Sebastian Kubosch
              phone_mobile: nil => "\\d{8}"
              email: "sebastian@example.com" => ".+"
              billing_email: nil => ".+"
              joined_on: Sat, 25 Aug 2007 => Tue, 21 Sep 2010
              parent_name: nil => ".+"
          Uwe Kubosch
              phone_mobile: nil => "\\d{8}"
              email: "uwe@example.com" => ".+"
              billing_email: nil => ".+"
              joined_on: Mon, 05 Jan 1987 => Fri, 15 Dec 2000
              parent_name: nil => ".+"
    EOF
    assert_match(/#{changes}/, mail.body.decoded)
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
          <td>2015-02-12</td>
        }x,
        mail.body.decoded
    assert_match %r{
          <td>Bastian\ Filip\ Krohn</td>\s*
          <td>Kasserer\ \(2\ år\)</td>\s*
          <td>2015-02-12</td>\s*
          <td></td>
        }x,
        mail.body.decoded
  end
end
