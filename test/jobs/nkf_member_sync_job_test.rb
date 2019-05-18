# frozen_string_literal: true

require 'test_helper'

class NkfMemberSyncJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test 'sync' do
    VCR.use_cassette('NKF Comparison', match_requests_on: %i[method host path query]) do
      assert_emails(0) { NkfMemberSyncJob.perform_now(members(:lars)) }
    end
  end
end
