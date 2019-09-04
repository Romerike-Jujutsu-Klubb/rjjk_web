# frozen_string_literal: true

require 'test_helper'

class NkfMemberComparisonTest < ActionMailer::TestCase
  def test_comparison
    c = nil
    VCR.use_cassette('NKF Comparison', match_requests_on: %i[method host path query]) do
      c = NkfMemberComparison.new.sync
    end
    assert_equal([], c.errors)
    assert_equal([
      members(:lars),
      members(:sebastian),
      members(:uwe),
    ], c.members)
    assert_equal([
      [members(:lars), {
        'joined_on' => [Date.parse('Thu, 21 Jun 2007'), Date.parse('Sun, 01 Apr 2001')],
        'user' => {
          'birthdate' => [Date.parse('Wed, 21 Jun 1967'), Date.parse('Wed, 01 Mar 1967')],
          'email' => ['lars@example.com', 'lars@example.net'],
          'latitude' => [nil, 40.714353], 'longitude' => [nil, -74.005973]
        },
      }],
      [members(:sebastian), {
        'joined_on' => [Date.parse('2007-08-25'), Date.parse('2007-09-21')],
        'user' => {
          'birthdate' => [Date.parse('2004-06-03'), Date.parse('2004-06-04')],
          'phone' => [nil, '92929292'],
          'email' => ['sebastian@example.com', 'sebastian@example.net'],
          'latitude' => [nil, 0.40714353e2], 'longitude' => [nil, -0.74005973e2]
        },
        'guardian_1' => {
          'email' => ['lise@example.com', nil],
        },
        'guardian_2' => {
          'first_name' => ['Uwe', ''], 'last_name' => ['Kubosch', nil]
        },
        'billing' => { 'email' => [nil, 'lise@example.net'] },
      }],
      [members(:uwe), {
        'user' => { 'email' => ['uwe@example.com', 'uwe@example.net'], 'latitude' => [nil, 0.40714353e2],
                    'longitude' => [nil, -0.74005973e2] },
      }],
    ], c.member_changes)
    assert_equal([
      [members(:lars), {
        { membership: :joined_on } => { Date.new(2001, 4, 1) => Date.new(2007, 6, 21) },
        { user: :birthdate } => { Date.new(1967, 3, 1) => Date.new(1967, 6, 21) },
        { user: :email } => { 'lars@example.net' => 'lars@example.com' },
      }],
      [members(:sebastian), {
        { membership: :joined_on } => { Date.parse('2007-09-21') => Date.parse('2007-08-25') },
        { user: :birthdate } => { Date.parse('2004-06-04') => Date.parse('2004-06-03') },
        { user: :phone } => { '92929292' => nil },
        { user: :email } => { 'sebastian@example.net' => 'sebastian@example.com' },
        { guardian_1: :email } => { nil => 'lise@example.com' },
        { guardian_2: :first_name } => { '' => 'Uwe Kubosch' },
        { guardian_2: :last_name } => { nil => 'Uwe Kubosch' },
        { billing: :email } => { 'lise@example.net' => nil },
      }],
      [members(:uwe), { { user: :email } => { 'uwe@example.net' => 'uwe@example.com' } }],
    ], c.outgoing_changes)
    assert_equal([Member.last], c.new_members)
    assert_equal([members(:leftie), members(:newbie), members(:oldie)], c.orphan_members)
    assert_equal([nkf_members(:erik)], c.orphan_nkf_members)
  end

  test 'sync single member with billing user change' do
    lars = members(:lars)
    lars.user.update! billing_user: users(:long_user)
    lars_nkf = nkf_members(:lars)
    lars_nkf.update! epost_faktura: users(:newbie).email
    c = nil
    VCR.use_cassette('NKF Comparison Single Member', match_requests_on: %i[method host path query]) do
      c = NkfMemberComparison.new(lars).sync
    end
    assert_equal([], c.errors)
    assert_equal([members(:lars)], c.members)
    assert_equal [[lars, {
      'joined_on' => [Date.new(2007, 6, 21), Date.new(2001, 4, 1)],
      'user' => { 'birthdate' => [Date.new(1967, 6, 21), Date.new(1967, 3, 1)],
                  'email' => %w[lars@example.com lars@example.net] },
      'billing' => { 'email' => %w[long_user@example.com newbie@example.com] },
    }]],
        c.member_changes
    assert_equal([
      [members(:lars), {
        { billing: :email } => { 'newbie@example.com' => 'long_user@example.com' },
        { membership: :joined_on } => { Date.new(2001, 4, 1) => Date.new(2007, 6, 21) },
        { user: :email } => { 'lars@example.net' => 'lars@example.com' },
        { user: :birthdate } => { Date.new(1967, 3, 1) => Date.new(1967, 6, 21) },
      }],
    ], c.outgoing_changes)
    assert_equal [nkf_members(:erik).member], c.new_members
    assert_equal([members(:leftie), members(:newbie), members(:oldie)], c.orphan_members)
    assert_equal([nkf_members(:erik)], c.orphan_nkf_members)
  end
end
