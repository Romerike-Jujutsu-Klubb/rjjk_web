# frozen_string_literal: true

require 'test_helper'

class NkfMemberImportTest < ActionMailer::TestCase
  def test_import_members
    AnnualMeeting.create! start_at: '2015-02-12 17:45'
    i = nil
    VCR.use_cassette('NKF Import Changes', match_requests_on: %i[method host path query body],
        allow_playback_repeats: true) do
      i = NkfMemberImport.new
    end

    assert_equal 3, i.changes.size
    assert_equal [], i.error_records
    assert_nil i.exception
    assert_equal 415, i.import_rows.size
    assert_equal 412, i.new_records.size
    assert(i.new_records
        .any? { |m| m[:record].etternavn == 'Aagren' && m[:record].fornavn == 'Sebastian' })
    assert(i.new_records.any? { |m| m[:record].etternavn == 'Øyan' && m[:record].fornavn == 'Erik' })
  end
end
