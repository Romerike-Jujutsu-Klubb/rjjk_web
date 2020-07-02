# frozen_string_literal: true

require 'test_helper'

class NkfMemberSyncJobTest < ActionMailer::TestCase
  test 'sync' do
    VCR.use_cassette('NkfMemberSyncJob_lars', match_requests_on: %i[method host path query]) do
      assert_emails(1) { NkfMemberSyncJob.perform_now(members(:lars)) }
      assert_equal <<~SUBJECTS.chomp, ActionMailer::Base.deliveries.map(&:subject).join("\n")
        [RJJK][TEST]  (RuntimeError) \"Failed to synchronize value with NKF member: id: 228855109, RJJK: membership.left_on: \\\"\\\"...
      SUBJECTS
    end
  end
end
