# encoding: utf-8
require 'test_helper'

class NkfMemberTrialMailerTest < ActionMailer::TestCase
  test 'notify_trial_end' do
    mail = NkfMemberTrialMailer.notify_trial_end
    assert_equal '[RJJK][TEST] Utløpt prøvetid', mail.subject
    assert_equal %w(to@example.org), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'Hi', mail.body.encoded
  end

  test 'notify_overdue_trials' do
    mail = NkfMemberTrialMailer.notify_overdue_trials([])
    assert_equal '[RJJK][TEST] Utløpt prøvetid', mail.subject
    assert_equal %w(uwe@kubosch.no), mail.to
    assert_equal %w(test@jujutsu.no), mail.from
    assert_match 'Følgende prøvemedlemmer har utløpt prøvetid', mail.body.encoded
  end

end
