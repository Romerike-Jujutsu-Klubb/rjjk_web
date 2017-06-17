# frozen_string_literal: true

require 'test_helper'

class NkfMemberComparisonTest < ActionMailer::TestCase
  def test_comparison
    VCR.use_cassette('NKF Comparison', match_requests_on: %i[method host path query]) do
      c = nil
      ActiveRecord::Base.transaction do
        c = NkfMemberComparison.new
        c.sync
      end
      assert_equal([], c.errors)
      assert_equal([
          members(:lars),
          members(:uwe),
      ], c.members)
      assert_equal([
          [members(:lars), {
              'birthdate' => [Date.parse('Wed, 21 Jun 1967'), Date.parse('Wed, 01 Mar 1967')],
              'email' => ['lars@example.com', 'lars@example.net'],
              'joined_on' => [Date.parse('Thu, 21 Jun 2007'), Date.parse('Sun, 01 Apr 2001')],
          }],
          [members(:uwe), {
              'email' => ['uwe@example.com', 'uwe@example.net'],
          }],
      ], c.member_changes)
      assert_equal([
          [members(:lars), {
              'birthdate' => { Date.new(1967, 3, 1) => Date.new(1967, 6, 21) },
              'email' => { 'lars@example.net' => 'lars@example.com' },
              'joined_on' => { Date.new(2001, 4, 1) => Date.new(2007, 6, 21) },
          }],
          [members(:uwe), { 'email' => { 'uwe@example.net' => 'uwe@example.com' } }],
      ], c.outgoing_changes)
      assert_equal([Member.last], c.new_members)
      assert_equal([members(:newbie), members(:sebastian)], c.orphan_members)
      assert_equal([nkf_members(:erik)], c.orphan_nkf_members)
    end
  end
end
