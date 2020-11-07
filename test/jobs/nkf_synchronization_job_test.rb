# frozen_string_literal: true

require 'test_helper'

class NkfSynchronizationJobTest < ActionMailer::TestCase
  setup { [:nkf_members].each { |t| ActiveRecord::Base.connection.reset_pk_sequence!(t) } }

  test 'perform' do
    users(:lars).update! email: 'lebraten@gmail.com'
    AnnualMeeting.create! start_at: '2015-02-12 17:45'
    assert_emails(3) do
      VCR.use_cassette('NKF Synchronization', match_requests_on: %i[method host path query body],
                                             allow_playback_repeats: true) do
        NkfSynchronizationJob.perform_now
      end
    end

    nkf_new_count = 474
    nkf_update_count = 3
    trial_changes = 20
    nkf_change_count = nkf_new_count + nkf_update_count + trial_changes
    import_mail = ActionMailer::Base.deliveries[0]
    import_body = import_mail.body.decoded
    assert_match(/^Hentet #{nkf_change_count} endringer fra NKF$/, import_mail.subject, import_body)
    assert_equal 'uwe@kubosch.no', import_mail.header[:to].value
    assert_equal 'noreply@test.jujutsu.no', import_mail.header[:from].value
    assert_match "NKF Import\r\n\r\nEndringer fra NKF-portalen.\r\n", import_body
    assert_match(/\b#{nkf_new_count} medlemmer opprettet\r\n#{nkf_update_count} medlemmer oppdatert\r\n/,
        import_body)
    assert_match "Endringer prøvetid:\r\n", import_body
    assert_match "Nye medlemmer:\r\n\r\n    Sebastian Aagren:\r\n", import_body

    rjjk_new_count = 467
    mail = ActionMailer::Base.deliveries[1]
    assert_match(/Oppdateringer fra NKF: #{rjjk_new_count} nye, 8 feil/, mail.subject)
    assert_equal 'uwe@kubosch.no', mail.header[:to].value
    assert_equal 'noreply@test.jujutsu.no', mail.header[:from].value
    assert_match(/Opprettet følgende nye medlemmer \(#{rjjk_new_count}\).*Abdorahman Lutf Muhammad/,
        mail.body.decoded)
    changes = file_fixture('nkf_synchronization_comparison_email.html').read.gsub("\r\n", "\n")
    expected_doc = Nokogiri::HTML(changes, &:noblanks)
    actual_doc = Nokogiri::HTML(mail.body.decoded.gsub("\r\n", "\n"), &:noblanks)

    expected_doc.xpath('//text()').each do |node|
      /\S/.match?(node.content) ? node.content = node.content.strip : node.remove
    end
    actual_doc.xpath('//text()').each do |node|
      /\S/.match?(node.content) ? node.content = node.content.strip : node.remove
    end

    # You can compare DOMS at http://prettydiff.com/
    diff = +''
    expected_doc.diff(actual_doc) do |change, node|
      next if change == ' '

      diff << "#{"#{change} #{node.to_html}".ljust(30)} #{node.parent.path}\n"
    end
    assert_empty diff, -> { "Expected:\n#{expected_doc}\nActual:\n#{actual_doc}\nDiff:\n#{diff}}" }

    mail = ActionMailer::Base.deliveries[2]
    assert_equal 'Verv fra NKF: 10', mail.subject
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
          <td>Bastian\ Filip\ Krohn</td>\s*
          <td>Kasserer\ \(2\ år\)</td>\s*
          <td>2015-02-12</td>\s*
          <td></td>
        }x,
        mail.body.decoded
    assert_equal [
      '<tr> <th align="left">Verv</th> <th>Navn</th> <th>Fra</th> <th>Til</th> </tr>',
      '<tr> <td colspan="4">Ukjent årsmøtedato: 01.01.2019 (Tollefsen Atle Kasserer)</td> </tr>',
      '<tr> <td>Uwe Kubosch</td> <td>Hovedinstruktør</td> <td>2013-01-01</td> <td></td> </tr>',
      '<tr> <td>Svein Robert Rolijordet</td> <td>Leder (2 år)</td> <td>2014-02-25</td> <td>2015-02-12</td> </tr>',
      '<tr> <td>Bastian Filip Krohn</td> <td>Kasserer (2 år)</td> <td>2015-02-12</td> <td></td> </tr>',
      '<tr> <td>Bastian Filip Krohn</td> <td>Kasserer (2 år)</td> <td>2015-02-12</td> <td></td> </tr>',
      '<tr> <td>Sara Madelen Musæus</td> <td>Materialforvalter</td> <td>2015-02-12</td> <td>2018-03-15</td> </tr>',
      '<tr> <td>Scott Jåfs Evensen</td> <td>Nestleder</td> <td>2015-02-12</td> <td>2017-02-28</td> </tr>',
      '<tr> <td>Atle Tollefsen</td> <td>Påmeldingsansvarlig</td> <td>2018-03-21</td> <td>2018-12-31</td> </tr>',
      '<tr> <td>Atle Tollefsen</td> <td>Medlemsansvarlig</td> <td>2018-03-21</td> <td>2018-12-31</td> </tr>',
      '<tr> <td>Curt Mekiassen</td> <td>Medlem</td> <td>2019-03-24</td> <td></td> </tr>',
    ], mail.body.decoded.gsub(/\s+/, ' ').scan(%r{<tr>.*?</tr>}m)
  end
end
