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
      [members(:lars), [
        { nkf_attr: 'fodselsdato', target: :user, target_attribute: :birthdate, nkf_value: '01.03.1967',
          mapped_nkf_value: Date.parse('Wed, 01 Mar 1967'), rjjk_value: Date.parse('Wed, 21 Jun 1967'),
          mapped_rjjk_value: '21.06.1967', form_field: :frm_48_v08 },
        { nkf_attr: 'epost', target: :user, target_attribute: :contact_email,
          nkf_value: 'lars@example.net', mapped_nkf_value: 'lars@example.net',
          rjjk_value: 'lars@example.com', mapped_rjjk_value: 'lars@example.com', form_field: :frm_48_v10 },
        { nkf_attr: 'innmeldtdato', target: :membership, target_attribute: :joined_on,
          nkf_value: '01.04.2001', mapped_nkf_value: Date.parse('Sun, 01 Apr 2001'),
          rjjk_value: Date.parse('Thu, 21 Jun 2007'), mapped_rjjk_value: '21.06.2007',
          form_field: :frm_48_v45 },
      ]],
      [members(:sebastian), [
        { nkf_attr: 'fodselsdato', target: :user, target_attribute: :birthdate, nkf_value: '04.06.2004',
          mapped_nkf_value: Date.parse('Fri, 04 Jun 2004'), rjjk_value: Date.parse('Thu, 03 Jun 2004'),
          mapped_rjjk_value: '03.06.2004', form_field: :frm_48_v08 },
        { nkf_attr: 'mobil', target: :user, target_attribute: :phone, nkf_value: '92929292',
          mapped_nkf_value: '92929292', rjjk_value: nil, mapped_rjjk_value: '', form_field: :frm_48_v20 },
        { nkf_attr: 'epost', target: :user, target_attribute: :contact_email,
          nkf_value: 'sebastian@example.net', mapped_nkf_value: 'sebastian@example.net',
          rjjk_value: 'sebastian@example.com', mapped_rjjk_value: 'sebastian@example.com',
          form_field: :frm_48_v10 },
        { nkf_attr: 'epost_faktura', target: :billing, target_attribute: :email,
          nkf_value: 'lise@example.net', mapped_nkf_value: 'lise@example.net', rjjk_value: nil,
          mapped_rjjk_value: '', form_field: :frm_48_v22 },
        { nkf_attr: 'innmeldtdato', target: :membership, target_attribute: :joined_on,
          nkf_value: '21.09.2007', mapped_nkf_value: Date.parse('Fri, 21 Sep 2007'),
          rjjk_value: Date.parse('Sat, 25 Aug 2007'), mapped_rjjk_value: '25.08.2007',
          form_field: :frm_48_v45 },
        { nkf_attr: 'foresatte_epost', target: :guardian_1, target_attribute: :email, nkf_value: '',
          mapped_nkf_value: nil, rjjk_value: 'lise@example.com', mapped_rjjk_value: 'lise@example.com',
          form_field: :frm_48_v73 },
        { nkf_attr: 'foresatte_nr_2', target: :guardian_2, target_attribute: :name, nkf_value: '',
          mapped_nkf_value: nil, rjjk_value: 'Uwe Kubosch', mapped_rjjk_value: 'Uwe Kubosch',
          form_field: :frm_48_v72 },
        { nkf_attr: 'foresatte_nr_2_mobil', target: :guardian_2, target_attribute: :phone, nkf_value: '',
          mapped_nkf_value: nil, rjjk_value: '5556666', mapped_rjjk_value: '5556666',
          form_field: :frm_48_v75 },
      ]],
      [members(:uwe), [
        { nkf_attr: 'mobil', target: :user, target_attribute: :phone, nkf_value: '', mapped_nkf_value: nil,
          rjjk_value: '5556666', mapped_rjjk_value: '5556666', form_field: :frm_48_v20 },
        { nkf_attr: 'epost', target: :user, target_attribute: :contact_email, nkf_value: 'uwe@example.net',
          mapped_nkf_value: 'uwe@example.net', rjjk_value: 'uwe@example.com',
          mapped_rjjk_value: 'uwe@example.com', form_field: :frm_48_v10 },
      ]],
    ], c.members)

    assert_equal([
      [members(:lars), {
        membership: { 'joined_on' => [Date.parse('Thu, 21 Jun 2007'), Date.parse('Sun, 01 Apr 2001')] },
        user: {
          'birthdate' => [Date.parse('Wed, 21 Jun 1967'), Date.parse('Wed, 01 Mar 1967')],
          'email' => ['lars@example.com', 'lars@example.net'],
        },
      }],
      [members(:sebastian), {
        membership: { 'joined_on' => [Date.parse('2007-08-25'), Date.parse('2007-09-21')] },
        user: {
          'birthdate' => [Date.parse('2004-06-03'), Date.parse('2004-06-04')],
          'phone' => [nil, '92929292'],
          'email' => ['sebastian@example.com', 'sebastian@example.net'],
        },
        guardian_1: { 'email' => ['lise@example.com', nil] },
        guardian_2: { 'first_name' => ['Uwe', ''], 'last_name' => ['Kubosch', nil], 'phone' => ['5556666', nil] },
        billing: { 'email' => [nil, 'lise@example.net'] },
      }],
      [members(:uwe), { user: { 'phone' => ['5556666', nil], 'email' => ['uwe@example.com', 'uwe@example.net'] } }],
    ], c.member_changes)

    assert_equal([
      [members(:lars), {
        { user: :birthdate } => { '01.03.1967' => '21.06.1967' },
        { user: :contact_email } => { 'lars@example.net' => 'lars@example.com' },
        { membership: :joined_on } => { '01.04.2001' => '21.06.2007' },
      }],
      [members(:sebastian), {
        { user: :birthdate } => { '04.06.2004' => '03.06.2004' },
        { user: :phone } => { '92929292' => '' },
        { user: :contact_email } => { 'sebastian@example.net' => 'sebastian@example.com' },
        { billing: :email } => { 'lise@example.net' => '' },
        { membership: :joined_on } => { '21.09.2007' => '25.08.2007' },
        { guardian_1: :email } => { '' => 'lise@example.com' },
        { guardian_2: :name } => { '' => 'Uwe Kubosch' },
        { guardian_2: :phone } => { '' => '5556666' },
      }],
      [members(:uwe), {
        { user: :phone } => { '' => '5556666' },
        { user: :contact_email } => { 'uwe@example.net' => 'uwe@example.com' },
      }],
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
    assert_equal([[
      members(:lars), [
        { nkf_attr: 'fodselsdato', target: :user, target_attribute: :birthdate,
          nkf_value: '01.03.1967', mapped_nkf_value: Date.parse('Wed,01 Mar 1967'),
          rjjk_value: Date.parse('Wed, 21 Jun 1967'), mapped_rjjk_value: '21.06.1967',
          form_field: :frm_48_v08 },
        { nkf_attr: 'epost', target: :user, target_attribute: :contact_email,
          nkf_value: 'lars@example.net', mapped_nkf_value: 'lars@example.net',
          rjjk_value: 'lars@example.com', mapped_rjjk_value: 'lars@example.com',
          form_field: :frm_48_v10 },
        { nkf_attr: 'epost_faktura', target: :billing, target_attribute: :email,
          nkf_value: 'newbie@example.com', mapped_nkf_value: 'newbie@example.com',
          rjjk_value: 'long_user@example.com', mapped_rjjk_value: 'long_user@example.com',
          form_field: :frm_48_v22 },
        { nkf_attr: 'innmeldtdato', target: :membership, target_attribute: :joined_on,
          nkf_value: '01.04.2001', mapped_nkf_value: Date.parse('Sun, 01 Apr 2001'),
          rjjk_value: Date.parse('Thu, 21 Jun 2007'), mapped_rjjk_value: '21.06.2007',
          form_field: :frm_48_v45 },
      ]
    ]], c.members)
    assert_equal [[lars, {
      membership: {
        'joined_on' => [Date.new(2007, 6, 21), Date.new(2001, 4, 1)],
      },
      user: {
        'birthdate' => [Date.new(1967, 6, 21), Date.new(1967, 3, 1)],
        'billing_user_id' => [226_069_790, 649_262_569],
        'email' => %w[lars@example.com lars@example.net],
      },
      billing: {
        'id' => [nil, 649_262_569], 'login' => [nil, 'newbie'],
        'salted_password' => [nil, 'de6db7cdf638e5ba522b9e5728d551315bf750f4'],
        'email' => [nil, 'newbie@example.com'], 'first_name' => [nil, 'Newbie'],
        'last_name' => [nil, 'Neuer'], 'salt' => [nil, '7f8b036f9b647d46d22abdbfc8113f44a88f9889'],
        'verified' => [nil, true], 'guardian_1_id' => [nil, 409_148_489],
        'address' => [nil, 'Rookie Road 5'], 'birthdate' => [nil, Date.parse('Thu, 17 May 1990')],
        'male' => [nil, true], 'postal_code' => [nil, '1472']
      },
    }]], c.member_changes

    assert_equal([[members(:lars), {
      { user: :birthdate } => { '01.03.1967' => '21.06.1967' },
      { user: :contact_email } => { 'lars@example.net' => 'lars@example.com' },
      { billing: :email } => { 'newbie@example.com' => 'long_user@example.com' },
      { membership: :joined_on } => { '01.04.2001' => '21.06.2007' },
    }]], c.outgoing_changes)

    assert_equal [nkf_members(:erik).member], c.new_members
    assert_equal([members(:leftie), members(:newbie), members(:oldie)], c.orphan_members)
    assert_equal([nkf_members(:erik)], c.orphan_nkf_members)
  end

  test 'sync single member with duplicate user phone' do
    seb = members(:sebastian)
    seb.nkf_member.update! foresatte_nr_2_mobil: seb.guardian_2.phone
    c = VCR.use_cassette('NKF Comparison Single Member', match_requests_on: %i[method host path query]) do
      NkfMemberComparison.new(seb).sync
    end
    assert_equal([], c.errors)
    assert_equal [[members(:sebastian), [
      { nkf_attr: 'fodselsdato', target: :user, target_attribute: :birthdate, nkf_value: '04.06.2004',
        mapped_nkf_value: Date.parse('Fri, 04 Jun 2004'), rjjk_value: Date.parse('Thu, 03 Jun 2004'),
        mapped_rjjk_value: '03.06.2004', form_field: :frm_48_v08 },
      { nkf_attr: 'mobil', target: :user, target_attribute: :phone, nkf_value: '92929292',
        mapped_nkf_value: '92929292', rjjk_value: nil, mapped_rjjk_value: '',
        form_field: :frm_48_v20 },
      { nkf_attr: 'epost', target: :user, target_attribute: :contact_email,
        nkf_value: 'sebastian@example.net', mapped_nkf_value: 'sebastian@example.net',
        rjjk_value: 'sebastian@example.com', mapped_rjjk_value: 'sebastian@example.com',
        form_field: :frm_48_v10 },
      { nkf_attr: 'epost_faktura', target: :billing, target_attribute: :email,
        nkf_value: 'lise@example.net', mapped_nkf_value: 'lise@example.net',
        rjjk_value: nil, mapped_rjjk_value: '', form_field: :frm_48_v22 },
      { nkf_attr: 'innmeldtdato', target: :membership, target_attribute: :joined_on,
        nkf_value: '21.09.2007', mapped_nkf_value: Date.parse('Fri, 21 Sep 2007'),
        rjjk_value: Date.parse('Sat, 25 Aug 2007'), mapped_rjjk_value: '25.08.2007',
        form_field: :frm_48_v45 },
      { nkf_attr: 'foresatte_epost', target: :guardian_1, target_attribute: :email, nkf_value: '',
        mapped_nkf_value: nil, rjjk_value: 'lise@example.com',
        mapped_rjjk_value: 'lise@example.com', form_field: :frm_48_v73 },
      { nkf_attr: 'foresatte_nr_2', target: :guardian_2, target_attribute: :name, nkf_value: '',
        mapped_nkf_value: nil, rjjk_value: 'Uwe Kubosch', mapped_rjjk_value: 'Uwe Kubosch',
        form_field: :frm_48_v72 },
    ]]], c.members

    assert_equal [[seb, {
      membership: { 'joined_on' => [Date.new(2007, 8, 25), Date.new(2007, 9, 21)] },
      user: { 'birthdate' => [Date.new(2004, 6, 3), Date.new(2004, 6, 4)],
              'phone' => [nil, '92929292'],
              'email' => %w[sebastian@example.com sebastian@example.net] },
      guardian_1: { 'email' => ['lise@example.com', nil] },
      guardian_2: { 'first_name' => ['Uwe', ''], 'last_name' => ['Kubosch', nil] },
      billing: { 'email' => [nil, 'lise@example.net'] },
    }]], c.member_changes

    assert_equal([
      [seb, {
        { membership: :joined_on } => { '21.09.2007' => '25.08.2007' },
        { user: :birthdate } => { '04.06.2004' => '03.06.2004' },
        { user: :phone } => { '92929292' => '' },
        { user: :contact_email } => { 'sebastian@example.net' => 'sebastian@example.com' },
        { guardian_1: :email } => { '' => 'lise@example.com' },
        { guardian_2: :name } => { '' => 'Uwe Kubosch' },
        { billing: :email } => { 'lise@example.net' => '' },
      }],
    ], c.outgoing_changes)

    assert_equal [nkf_members(:erik).member], c.new_members
    assert_equal([members(:leftie), members(:newbie), members(:oldie)], c.orphan_members)
    assert_equal([nkf_members(:erik)], c.orphan_nkf_members)
  end
end
