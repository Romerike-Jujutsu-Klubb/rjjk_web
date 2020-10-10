# frozen_string_literal: true

require 'test_helper'

class NkfMemberTrialImportTest < ActionMailer::TestCase
  def test_import_trial_members
    i = nil
    VCR.use_cassette('NKF Import Trial Changes', match_requests_on: %i[method host path query body],
        allow_playback_repeats: true) do
      i = NkfMemberTrialImport.new
    end

    assert_equal [], i.error_records
    assert_nil i.exception
    assert_equal 17, i.trial_changes.size
  end
end
