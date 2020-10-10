# frozen_string_literal: true

require 'test_helper'

class NkfReplicationMailerTest < ActionMailer::TestCase
  test 'import_changes' do
    import = mock('import')
    import.stubs(:size).returns(1)
    import.stubs(:new_records).returns([])
    import.stubs(:changes).returns({})
    import.stubs(:error_records).returns([])
    import.stubs(:import_rows).returns([1])
    import.stubs(:exception).returns(nil)
    trial_import = mock('trial_import')
    trial_import.stubs(:trial_changes).returns([])
    trial_import.stubs(:exception).returns(nil)
    trial_import.stubs(:size).returns(0)

    mail = NkfReplicationMailer.import_changes(import, trial_import)
    assert_equal 'Hentet 1 endringer fra NKF', mail.subject
    assert_equal ['uwe@kubosch.no'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match(/NKF Import\s+Endringer fra NKF-portalen.\s+/, mail.body.encoded)
  end

  test 'update_members' do
    comparison = mock('comparison')
    comparison.stubs(:new_members).returns([mock('new_member', name: 'Erik Hansen')])
    comparison.stubs(:outgoing_changes)
        .returns([[mock('outgoing_changes', name: 'Hans Eriksen'), { 'email' => { 'H@ans' => 'Ha@ns' } }]])
    comparison.stubs(:errors).returns([])
    mail = NkfReplicationMailer.update_members(comparison)
    assert_equal 'Oppdateringer fra NKF: 1 nye', mail.subject
    assert_equal ['uwe@kubosch.no'], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match(/Opprettet følgende nye medlemmer.*Erik Hansen.*Ville ha oppdatert følgende medlemmer hos NKF.*Hans Eriksen.*email.*"H@ans" => "Ha@ns"/, # rubocop: disable Layout/LineLength
        mail.body.decoded.gsub('&quot;', '"').gsub('&gt;', '>'))
  end
end
