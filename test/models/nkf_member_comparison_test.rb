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
          members(:sebastian),
          members(:uwe),
      ], c.members)
      assert_equal([
          [members(:lars), {
              'birthdate' => [Date.parse('Wed, 21 Jun 1967'), Date.parse('Wed, 01 Mar 1967')],
              'email' => ['lars@example.com', 'lars@example.net'],
              'joined_on' => [Date.parse('Thu, 21 Jun 2007'), Date.parse('Sun, 01 Apr 2001')],
          }],
          [members(:sebastian), {
              'birthdate' => [Date.parse('2004-06-03'), Date.parse('2004-06-04')],
              'phone_mobile' => [nil, '92929292'],
              'email' => ['sebastian@example.com', 'sebastian@example.net'],
              'billing_email' => [nil, 'lise@example.net'],
              'joined_on' => [Date.parse('2010-08-25'), Date.parse('2010-09-21')],
              'parent_name' => [nil, 'Lise Kubosch'],
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
          [members(:sebastian), {
              'birthdate' => { Date.parse('2004-06-04') => Date.parse('2004-06-03') },
              'phone_mobile' => { '92929292' => nil },
              'email' => { 'sebastian@example.net' => 'sebastian@example.com' },
              'billing_email' => { 'lise@example.net' => nil },
              'joined_on' => { Date.parse('2010-09-21') => Date.parse('2010-08-25') },
              'parent_name' => { 'Lise Kubosch' => nil },
          }],
          [members(:uwe), { 'email' => { 'uwe@example.net' => 'uwe@example.com' } }],
      ], c.outgoing_changes)
      assert_equal([Member.last], c.new_members)
      assert_equal([members(:newbie)], c.orphan_members)
      assert_equal([nkf_members(:erik)], c.orphan_nkf_members)
    end
  end
end
