require 'test_helper'

class NkfMemberTrialMailerTest < ActionMailer::TestCase
  test "notify_trial_end" do
    mail = NkfMemberTrialMailer.notify_trial_end
    assert_equal "Notify trial end", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "notify_overdue_trials" do
    mail = NkfMemberTrialMailer.notify_overdue_trials
    assert_equal "Notify overdue trials", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
