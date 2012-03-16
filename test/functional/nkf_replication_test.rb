# encoding: UTF-8
require 'test_helper'

class NkfReplicationTest < ActionMailer::TestCase
  test "import_changes" do
    import = mock('import')
    import.stubs(:size).returns(1)
    import.stubs(:changes).returns([1])
    import.stubs(:error_records).returns([])
    import.stubs(:import_rows).returns([1])

    mail = NkfReplication.import_changes(import)
    assert_equal "Hentet 1 endringer fra NKF", mail.subject
    assert_equal ["uwe@kubosch.no"], mail.to
    assert_equal ["webmaster@jujutsu.no"], mail.from
    assert_match "NKF Import\r\n\r\nImporterte endringer fra NKF-portalen.\r\n\r\n1 records importert,\r\n0 feilet,\r\n0 uendret.\r\n\r\n", mail.body.encoded
  end

  test "update_members" do
    new_members, member_changes, group_changes =
        [mock('new_member', :first_name => 'Erik', :last_name => 'Hansen')],
            [[mock('member_change', :first_name => 'Erik', :last_name => 'Hansen'), {'first_name' => 'Hans'}]],
            {mock(:first_name => 'hhh', :last_name => 'dfgfg') => [[mock('added_group', :name => 'hhgf')], [mock('removed_group', :name => 'abc')]]}
    mail = NkfReplication.update_members(new_members, member_changes, group_changes)
    assert_equal "Oppdateringer fra NKF: 1 nye, 1 endrede, 1 gruppeendringer", mail.subject
    assert_equal ["uwe@kubosch.no"], mail.to
    assert_equal ["webmaster@jujutsu.no"], mail.from
    assert_match "Opprettet følgende nye medlemmer:\r\n\r\nErik Hansen\r\n\r\nOppdaterte følgende eksisterende medlemmer:\r\n\r\nErik Hansen\r\n    first_name: H => a\r\n\r\nGruppemedlemskap:\r\n\r\nhhh dfgfg\r\n    Lagt til: hhgf\r\n    Fjernet : abc\r\n\r\n", mail.body.encoded
  end

end
