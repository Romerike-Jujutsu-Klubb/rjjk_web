# frozen_string_literal: true

require 'test_helper'

class NkfMemberImportTest < ActionMailer::TestCase
  # ================================================================================
  # An HTTP request has been made that VCR does not know how to handle:
  #   GET http://nkfwww.kampsport.no/portal/page/portal/ks_utv/ks_medlprofil?p_cr_par=DBD1D1D8CD9CD9B1979DA36963A3B3A292E3C7CEDD97CFCE72AC609F9894D3C1D1C9DDE6B0B09B9AA06765989694696AB19CAB9BACAAA5A29399A99C
  #
  # VCR is currently using the following cassette:
  #   - /Users/uwe/work/rjjk/rjjk_web/test/vcr_cassettes/NKF_Import_Changes.yml
  #     - :record => :once
  #     - :match_requests_on => [:method, :host, :path, :query]
  #
  # Under the current configuration VCR can not find a suitable HTTP interaction
  # to replay and is prevented from recording new requests. There are a few ways
  # you can deal with this:
  #
  #   * If you're surprised VCR is raising this error
  #     and want insight about how VCR attempted to handle the request,
  #     you can use the debug_logger configuration option to log more details [1].
  #   * You can use the :new_episodes record mode to allow VCR to
  #     record this new request to the existing cassette [2].
  #   * If you want VCR to ignore this request (and others like it), you can
  #     set an `ignore_request` callback [3].
  #   * The current record mode (:once) does not allow new requests to be recorded
  #     to a previously recorded cassette. You can delete the cassette file and re-run
  #     your tests to allow the cassette to be recorded with this request [4].
  #   * The cassette contains 666 HTTP interactions that have not been
  #     played back. If your request is non-deterministic, you may need to
  #     change your :match_requests_on cassette option to be more lenient
  #     or use a custom request matcher to allow it to match [5].
  #
  # [1] https://www.relishapp.com/vcr/vcr/v/3-0-3/docs/configuration/debug-logging
  # [2] https://www.relishapp.com/vcr/vcr/v/3-0-3/docs/record-modes/new-episodes
  # [3] https://www.relishapp.com/vcr/vcr/v/3-0-3/docs/configuration/ignore-request
  # [4] https://www.relishapp.com/vcr/vcr/v/3-0-3/docs/record-modes/once
  # [5] https://www.relishapp.com/vcr/vcr/v/3-0-3/docs/request-matching
  # ================================================================================

  def test_import_members
    AnnualMeeting.create! start_at: '2015-02-12 17:45'
    VCR.use_cassette('NKF Import Changes', match_requests_on: %i(method host path query),
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
    assert_match(/Oppdateringer fra NKF: \d{3} nye, 2 endrede, \d{3} gruppeendringer/, mail.subject)
    assert_equal 'uwe@kubosch.no', mail.header[:to].value
    assert_equal 'noreply@test.jujutsu.no', mail.header[:from].value
    assert_match "Opprettet følgende nye medlemmer:\n\n    Abdorahman Lutf Muhammad\n",
        mail.body.decoded

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
