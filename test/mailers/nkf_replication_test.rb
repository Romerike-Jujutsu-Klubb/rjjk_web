require 'test_helper'

class NkfReplicationTest < ActionMailer::TestCase
  test 'import_changes' do
    import = mock('import')
    import.stubs(:size).returns(1)
    import.stubs(:new_records).returns([])
    import.stubs(:changes).returns({})
    import.stubs(:trial_changes).returns([])
    import.stubs(:error_records).returns([])
    import.stubs(:import_rows).returns([1])
    import.stubs(:exception).returns(nil)

    mail = NkfReplicationMailer.import_changes(import)
    assert_equal '[RJJK][TEST] Hentet 1 endringer fra NKF', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match /NKF Import\s+Endringer fra NKF-portalen.\s+/, mail.body.encoded
  end

  test 'update_members' do
    comparison = mock('comparison')
    comparison.stubs(:new_members).returns([mock('new_member', :first_name => 'Erik', :last_name => 'Hansen')])
    comparison.stubs(:member_changes).returns([[mock('member_change', :first_name => 'Erik', :last_name => 'Hansen'), { 'first_name' => 'Hans' }]])
    comparison.stubs(:group_changes).returns({ mock(:first_name => 'hhh', :last_name => 'dfgfg') => [[mock('added_group', :name => 'hhgf')], [mock('removed_group', :name => 'abc')]] })
    comparison.stubs(:errors).returns([])
    mail = NkfReplicationMailer.update_members(comparison)
    assert_equal '[RJJK][TEST] Oppdateringer fra NKF: 1 nye, 1 endrede, 1 gruppeendringer', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match /Opprettet følgende nye medlemmer:\s+Erik Hansen\s+Oppdaterte følgende eksisterende medlemmer:\s+Erik Hansen\s+first_name: "H" => "a"\s+Gruppemedlemskap:\s+hhh dfgfg\s+Lagt til: hhgf\s+Fjernet : abc/, mail.body.encoded
  end
end
