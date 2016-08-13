require 'test_helper'

class NkfMemberTrialMailerTest < ActionMailer::TestCase
  test 'notify_trial_end' do
    mail = NkfMemberTrialMailer.notify_trial_end(nkf_member_trials(:one))
    assert_equal '[RJJK][TEST] Utløpt prøvetid', mail.subject
    assert_equal %w(to@example.org), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'Hei Hans Eriksen!', mail.body.decoded
  end

  test 'notify_overdue_trials' do
    mail = NkfMemberTrialMailer.notify_overdue_trials(users(:admin), [])
    assert_equal '[RJJK][TEST] Utløpt prøvetid', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'Følgende prøvemedlemmer har utløpt prøvetid', mail.body.decoded
  end

end
