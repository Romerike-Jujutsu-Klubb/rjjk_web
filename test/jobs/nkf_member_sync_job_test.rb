# frozen_string_literal: true

require 'test_helper'

class NkfMemberSyncJobTest < ActiveJob::TestCase
  test 'sync' do
    VCR.use_cassette('NKF Comparison', match_requests_on: %i[method host path query]) do
      NkfMemberSyncJob.perform_now(members(:lars))
    end
  end
end
