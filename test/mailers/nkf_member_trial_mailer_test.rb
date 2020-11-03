# frozen_string_literal: true

require 'test_helper'

class NkfMemberTrialMailerTest < ActionMailer::TestCase
  test 'notify_trial_end' do
    mail = NkfMemberTrialMailer.notify_trial_end(nkf_member_trials(:hans))
    assert_equal 'Utløpt prøvetid', mail.subject
    assert_equal %w[to@example.org], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match 'Hei Hans Eriksen!', mail.body.decoded
  end

  test 'notify_overdue_trials' do
    mail = NkfMemberTrialMailer.notify_overdue_trials(users(:uwe), [])
    assert_equal 'Utløpt prøvetid', mail.subject
    assert_equal %w[uwe@example.com], mail.to
    assert_equal %w[noreply@test.jujutsu.no], mail.from
    assert_match 'Følgende prøvemedlemmer har utløpt prøvetid', mail.body.decoded
  end
end
