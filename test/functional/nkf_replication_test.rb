require 'test_helper'

class NkfReplicationTest < ActionMailer::TestCase
  test "import_changes" do
    mail = NkfReplication.import_changes
    assert_equal "Import changes", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "synchronize" do
    mail = NkfReplication.update_members
    assert_equal "Synchronize", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
