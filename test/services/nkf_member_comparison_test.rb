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
        { nkf_attr: :epost, target: :user, target_attribute: :contact_email,
          nkf_value: 'lars@example.net', mapped_nkf_value: 'lars@example.net',
          rjjk_value: 'lars@example.com', mapped_rjjk_value: 'lars@example.com',
          form_field: { member: :frm_48_v10, new_trial: :frm_29_v10, trial: :frm_28_v24 } },
        { nkf_attr: :fodselsdato, target: :user, target_attribute: :birthdate, nkf_value: '01.03.1967',
          mapped_nkf_value: Date.parse('Wed, 01 Mar 1967'), rjjk_value: Date.parse('Wed, 21 Jun 1967'),
          mapped_rjjk_value: '21.06.1967',
          form_field: { member: :frm_48_v08, new_trial: :frm_29_v08, trial: :frm_28_v14 } },
        { nkf_attr: :gren_stilart_avd_parti___gren_stilart_avd_parti, target: :membership,
          target_attribute: :martial_art_name,
          nkf_value: 'Jujutsu/Jujutsu (Ingen stilartstilknytning)/Strømmen Storsenter/Voksne',
          mapped_nkf_value: 'Jujutsu/Jujutsu (Ingen stilartstilknytning)/Strømmen Storsenter/Voksne',
          rjjk_value: 'Kei Wa Ryu', mapped_rjjk_value: 'Jujutsu (Ingen stilartstilknytning)',
          form_field: { new_trial: :frm_29_v16, trial: :frm_28_v28 } },
        { nkf_attr: :innmeldtdato, target: :membership, target_attribute: :joined_on,
          nkf_value: '01.04.2001', mapped_nkf_value: Date.parse('Sun, 01 Apr 2001'),
          rjjk_value: Date.parse('Thu, 21 Jun 2007'), mapped_rjjk_value: '21.06.2007',
          form_field: { member: :frm_48_v45, trial: :frm_28_v64 } },
        { nkf_attr: :kjonn, target: :user, target_attribute: :male, nkf_value: 'Mann',
          mapped_nkf_value: true, rjjk_value: true, mapped_rjjk_value: 'M',
          form_field: { member: :frm_48_v112, new_trial: :frm_29_v11, trial: :frm_28_v15 } },
        { nkf_attr: :kont_sats, target: :membership, target_attribute: :category, nkf_value: nil,
          mapped_nkf_value: nil, rjjk_value: 'Voksen', mapped_rjjk_value: 'Voksen',
          form_field: { member: :frm_48_v36, trial: :frm_28_v34 } },
        { nkf_attr: :kontraktsbelop, target: :membership, target_attribute: :monthly_fee, nkf_value: nil,
          mapped_nkf_value: nil, rjjk_value: 0, mapped_rjjk_value: '0', form_field: { trial: :frm_28_v63 } },
        { nkf_attr: :kontraktstype, target: :membership, target_attribute: :contract, nkf_value: nil,
          mapped_nkf_value: nil, rjjk_value: 'Voksen', mapped_rjjk_value: 'Voksen',
          form_field: { member: :frm_48_v37, trial: :frm_28_v36 } },
        { nkf_attr: :medlemskategori_navn, target: :membership, target_attribute: :category,
          nkf_value: nil, mapped_nkf_value: nil, rjjk_value: 'Voksen', mapped_rjjk_value: 'Voksen',
          form_field: { member: :frm_48_v48, trial: :frm_28_v17 } },
        { nkf_attr: :rabatt, target: :membership, target_attribute: :discount, nkf_value: nil,
          mapped_nkf_value: nil, rjjk_value: 100, mapped_rjjk_value: '100',
          form_field: { member: :frm_48_v38, trial: :frm_28_v35 } },
      ]],
      [members(:sebastian), [
        { nkf_attr: :epost, target: :user, target_attribute: :contact_email,
          nkf_value: 'sebastian@example.net', mapped_nkf_value: 'sebastian@example.net',
          rjjk_value: 'sebastian@example.com', mapped_rjjk_value: 'sebastian@example.com',
          form_field: { member: :frm_48_v10, new_trial: :frm_29_v10, trial: :frm_28_v24 } },
        { nkf_attr: :epost_faktura, target: :billing, target_attribute: :email,
          nkf_value: 'lise@example.net', mapped_nkf_value: 'lise@example.net', rjjk_value: nil,
          mapped_rjjk_value: '',
          form_field: { member: :frm_48_v22, new_trial: :frm_29_v22, trial: :frm_28_v25 } },
        { nkf_attr: :fodselsdato, target: :user, target_attribute: :birthdate, nkf_value: '04.06.2004',
          mapped_nkf_value: Date.parse('Fri, 04 Jun 2004'), rjjk_value: Date.parse('Thu, 03 Jun 2004'),
          mapped_rjjk_value: '03.06.2004',
          form_field: { member: :frm_48_v08, new_trial: :frm_29_v08, trial: :frm_28_v14 } },
        { nkf_attr: :foresatte_epost, target: :guardian_1, target_attribute: :email, nkf_value: '',
          mapped_nkf_value: nil, rjjk_value: 'lise@example.com', mapped_rjjk_value: 'lise@example.com',
          form_field: { member: :frm_48_v73, new_trial: :frm_29_v73, trial: :frm_a28_v73 } },
        { nkf_attr: :foresatte_nr_2, target: :guardian_2, target_attribute: :name, nkf_value: '',
          mapped_nkf_value: nil, rjjk_value: 'Uwe Kubosch', mapped_rjjk_value: 'Uwe Kubosch',
          form_field: { member: :frm_48_v72, new_trial: :frm_29_v72, trial: :frm_a28_v72 } },
        { nkf_attr: :foresatte_nr_2_mobil, target: :guardian_2, target_attribute: :phone, nkf_value: '',
          mapped_nkf_value: nil, rjjk_value: '55569666', mapped_rjjk_value: '55569666',
          form_field: { member: :frm_48_v75, new_trial: :frm_29_v75, trial: :frm_a28_v75 } },
        { nkf_attr: :gren_stilart_avd_parti___gren_stilart_avd_parti, target: :membership,
          target_attribute: :martial_art_name,
          nkf_value: 'Jujutsu/Jujutsu (Ingen stilartstilknytning)/Strømmen Storsenter/Tiger',
          mapped_nkf_value: 'Jujutsu/Jujutsu (Ingen stilartstilknytning)/Strømmen Storsenter/Tiger',
          rjjk_value: 'Kei Wa Ryu', mapped_rjjk_value: 'Jujutsu (Ingen stilartstilknytning)',
          form_field: { new_trial: :frm_29_v16, trial: :frm_28_v28 } },
        { nkf_attr: :innmeldtdato, target: :membership, target_attribute: :joined_on,
          nkf_value: '21.09.2007', mapped_nkf_value: Date.parse('Fri, 21 Sep 2007'),
          rjjk_value: Date.parse('Sat, 25 Aug 2007'), mapped_rjjk_value: '25.08.2007',
          form_field: { member: :frm_48_v45, trial: :frm_28_v64 } },
        { nkf_attr: :kjonn, target: :user, target_attribute: :male, nkf_value: 'Mann',
          mapped_nkf_value: true, rjjk_value: true, mapped_rjjk_value: 'M',
          form_field: { member: :frm_48_v112, new_trial: :frm_29_v11, trial: :frm_28_v15 } },
        { nkf_attr: :kont_sats, target: :membership, target_attribute: :category,
          nkf_value: 'Passiv sats', mapped_nkf_value: 'Passiv sats', rjjk_value: 'Barn',
          mapped_rjjk_value: 'Barn', form_field: { member: :frm_48_v36, trial: :frm_28_v34 } },
        { nkf_attr: :kontraktstype, target: :membership, target_attribute: :contract,
          nkf_value: 'Passiv - Ungdom', mapped_nkf_value: 'Passiv - Ungdom', rjjk_value: 'Barn - familie',
          mapped_rjjk_value: 'Barn - familie', form_field: { member: :frm_48_v37, trial: :frm_28_v36 } },
        { nkf_attr: :medlemskategori_navn, target: :membership, target_attribute: :category,
          nkf_value: 'Passiv', mapped_nkf_value: 'Passiv', rjjk_value: 'Barn', mapped_rjjk_value: 'Barn',
          form_field: { member: :frm_48_v48, trial: :frm_28_v17 } },
        { nkf_attr: :mobil, target: :user, target_attribute: :phone, nkf_value: '92929292',
          mapped_nkf_value: '92929292', rjjk_value: nil, mapped_rjjk_value: '',
          form_field: { member: :frm_48_v20, new_trial: :frm_29_v20, trial: :frm_28_v22 } },
        { nkf_attr: :rabatt, target: :membership, target_attribute: :discount, nkf_value: nil,
          mapped_nkf_value: nil, rjjk_value: 100, mapped_rjjk_value: '100',
          form_field: { member: :frm_48_v38, trial: :frm_28_v35 } },
      ]],
      [members(:uwe), [
        { nkf_attr: :epost, target: :user, target_attribute: :contact_email, nkf_value: 'uwe@example.net',
          mapped_nkf_value: 'uwe@example.net', rjjk_value: 'uwe@example.com',
          mapped_rjjk_value: 'uwe@example.com',
          form_field: { member: :frm_48_v10, new_trial: :frm_29_v10, trial: :frm_28_v24 } },
        { nkf_attr: :gren_stilart_avd_parti___gren_stilart_avd_parti, target: :membership,
          target_attribute: :martial_art_name,
          nkf_value: 'Jujutsu/Jujutsu (Ingen stilartstilknytning)/Strømmen Storsenter/Voksne',
          mapped_nkf_value: 'Jujutsu/Jujutsu (Ingen stilartstilknytning)/Strømmen Storsenter/Voksne',
          rjjk_value: 'Kei Wa Ryu', mapped_rjjk_value: 'Jujutsu (Ingen stilartstilknytning)',
          form_field: { new_trial: :frm_29_v16, trial: :frm_28_v28 } },
        { nkf_attr: :kjonn, target: :user, target_attribute: :male, nkf_value: 'Mann',
          mapped_nkf_value: true, rjjk_value: true, mapped_rjjk_value: 'M',
          form_field: { member: :frm_48_v112, new_trial: :frm_29_v11, trial: :frm_28_v15 } },
        { nkf_attr: :kont_sats, target: :membership, target_attribute: :category, nkf_value: nil,
          mapped_nkf_value: nil, rjjk_value: 'Voksen', mapped_rjjk_value: 'Voksen',
          form_field: { member: :frm_48_v36, trial: :frm_28_v34 } },
        { nkf_attr: :kontraktsbelop, target: :membership, target_attribute: :monthly_fee, nkf_value: nil,
          mapped_nkf_value: nil, rjjk_value: 0, mapped_rjjk_value: '0', form_field: { trial: :frm_28_v63 } },
        { nkf_attr: :kontraktstype, target: :membership, target_attribute: :contract, nkf_value: nil,
          mapped_nkf_value: nil, rjjk_value: 'Voksen', mapped_rjjk_value: 'Voksen',
          form_field: { member: :frm_48_v37, trial: :frm_28_v36 } },
        { nkf_attr: :medlemskategori_navn, target: :membership, target_attribute: :category,
          nkf_value: nil, mapped_nkf_value: nil, rjjk_value: 'Voksen', mapped_rjjk_value: 'Voksen',
          form_field: { member: :frm_48_v48, trial: :frm_28_v17 } },
        { nkf_attr: :mobil, target: :user, target_attribute: :phone, nkf_value: '', mapped_nkf_value: nil,
          rjjk_value: '55569666', mapped_rjjk_value: '55569666',
          form_field: { member: :frm_48_v20, new_trial: :frm_29_v20, trial: :frm_28_v22 } },
        { nkf_attr: :rabatt, target: :membership, target_attribute: :discount, nkf_value: nil,
          mapped_nkf_value: nil, rjjk_value: 100, mapped_rjjk_value: '100',
          form_field: { member: :frm_48_v38, trial: :frm_28_v35 } },
      ]],
    ], c.members)

    assert_equal([
      [members(:lars), {
        { user: :contact_email } => { 'lebraten@gmail.com' => 'lars@example.com' },
        { user: :birthdate } => { '24.03.1968' => '21.06.1967' },
        { membership: :joined_on } => { '14.10.2003' => '21.06.2007' },
        { user: :male } => { 'M' => 'M' },
        { membership: :category } => { nil => 'Voksen' },
        { membership: :contract } => { nil => 'Voksen' },
        { membership: :discount } => { '50' => '100' },
      }],
      [members(:sebastian), {
        { user: :contact_email } => { 'sebastian@kubosch.no' => 'sebastian@example.com' },
        { billing: :email } => { 'lise@kubosch.no' => '' },
        { user: :birthdate } => { '03.06.2004' => '03.06.2004' },
        { guardian_1: :email } => { 'lise@kubosch.no' => 'lise@example.com' },
        { guardian_2: :name } => { 'Uwe Kubosch' => 'Uwe Kubosch' },
        { guardian_2: :phone } => { '92206046' => '55569666' },
        { membership: :joined_on } => { '21.09.2010' => '25.08.2007' },
        { user: :male } => { 'M' => 'M' },
        { membership: :category } => { nil => 'Barn' },
        { membership: :contract } => { nil => 'Barn - familie' },
        { membership: :discount } => { '' => '100' },
      }],
      [members(:uwe), {
        { user: :contact_email } => { 'uwe@kubosch.no' => 'uwe@example.com' },
        { user: :male } => { 'M' => 'M' },
        { membership: :category } => { nil => 'Voksen' },
        { membership: :contract } => { nil => 'Voksen' },
        { user: :phone } => { '92206046' => '55569666' },
        { membership: :discount } => { '' => '100' },
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
        { nkf_attr: :epost, target: :user, target_attribute: :contact_email,
          nkf_value: 'lars@example.net', mapped_nkf_value: 'lars@example.net',
          rjjk_value: 'lars@example.com', mapped_rjjk_value: 'lars@example.com',
          form_field: { member: :frm_48_v10, new_trial: :frm_29_v10, trial: :frm_28_v24 } },
        { nkf_attr: :epost_faktura, target: :billing, target_attribute: :email,
          nkf_value: 'newbie@example.com', mapped_nkf_value: 'newbie@example.com',
          rjjk_value: 'long_user@example.com', mapped_rjjk_value: 'long_user@example.com',
          form_field: { member: :frm_48_v22, new_trial: :frm_29_v22, trial: :frm_28_v25 } },
        { nkf_attr: :fodselsdato, target: :user, target_attribute: :birthdate,
          nkf_value: '01.03.1967', mapped_nkf_value: Date.parse('Wed,01 Mar 1967'),
          rjjk_value: Date.parse('Wed, 21 Jun 1967'), mapped_rjjk_value: '21.06.1967',
          form_field: { member: :frm_48_v08, new_trial: :frm_29_v08, trial: :frm_28_v14 } },
        { nkf_attr: :gren_stilart_avd_parti___gren_stilart_avd_parti, target: :membership,
          target_attribute: :martial_art_name,
          nkf_value: 'Jujutsu/Jujutsu (Ingen stilartstilknytning)/Strømmen Storsenter/Voksne',
          mapped_nkf_value: 'Jujutsu/Jujutsu (Ingen stilartstilknytning)/Strømmen Storsenter/Voksne',
          rjjk_value: 'Kei Wa Ryu', mapped_rjjk_value: 'Jujutsu (Ingen stilartstilknytning)',
          form_field: { new_trial: :frm_29_v16, trial: :frm_28_v28 } },
        { nkf_attr: :innmeldtdato, target: :membership, target_attribute: :joined_on,
          nkf_value: '01.04.2001', mapped_nkf_value: Date.parse('Sun, 01 Apr 2001'),
          rjjk_value: Date.parse('Thu, 21 Jun 2007'), mapped_rjjk_value: '21.06.2007',
          form_field: { member: :frm_48_v45, trial: :frm_28_v64 } },
        { nkf_attr: :kjonn, target: :user, target_attribute: :male, nkf_value: 'Mann',
          mapped_nkf_value: true, rjjk_value: true, mapped_rjjk_value: 'M',
          form_field: { member: :frm_48_v112, new_trial: :frm_29_v11, trial: :frm_28_v15 } },
        { nkf_attr: :kont_sats, target: :membership, target_attribute: :category, nkf_value: nil,
          mapped_nkf_value: nil, rjjk_value: 'Voksen', mapped_rjjk_value: 'Voksen',
          form_field: { member: :frm_48_v36, trial: :frm_28_v34 } },
        { nkf_attr: :kontraktsbelop, target: :membership, target_attribute: :monthly_fee, nkf_value: nil,
          mapped_nkf_value: nil, rjjk_value: 0, mapped_rjjk_value: '0', form_field: { trial: :frm_28_v63 } },
        { nkf_attr: :kontraktstype, target: :membership, target_attribute: :contract, nkf_value: nil,
          mapped_nkf_value: nil, rjjk_value: 'Voksen', mapped_rjjk_value: 'Voksen',
          form_field: { member: :frm_48_v37, trial: :frm_28_v36 } },
        { nkf_attr: :medlemskategori_navn, target: :membership, target_attribute: :category,
          nkf_value: nil, mapped_nkf_value: nil, rjjk_value: 'Voksen', mapped_rjjk_value: 'Voksen',
          form_field: { member: :frm_48_v48, trial: :frm_28_v17 } },
        { nkf_attr: :rabatt, target: :membership, target_attribute: :discount, nkf_value: nil,
          mapped_nkf_value: nil, rjjk_value: 100, mapped_rjjk_value: '100',
          form_field: { member: :frm_48_v38, trial: :frm_28_v35 } },
      ]
    ]], c.members)

    assert_equal([[members(:lars), {
      { user: :contact_email } => { 'lebraten@gmail.com' => 'lars@example.com' },
      { billing: :email } => { '' => 'long_user@example.com' },
      { user: :birthdate } => { '24.03.1968' => '21.06.1967' },
      { membership: :joined_on } => { '14.10.2003' => '21.06.2007' },
      { user: :male } => { 'M' => 'M' },
      { membership: :category } => { nil => 'Voksen' },
      { membership: :contract } => { nil => 'Voksen' },
      { membership: :discount } => { '50' => '100' },
    }]], c.outgoing_changes)

    assert_equal [nkf_members(:erik).member], c.new_members
    assert_equal([members(:leftie), members(:newbie), members(:oldie)], c.orphan_members)
    assert_equal([nkf_members(:erik)], c.orphan_nkf_members)
  end

  test 'sync single member with duplicate user phone' do
    seb = members(:sebastian)
    seb.nkf_member.update! foresatte_nr_2_mobil: seb.guardian_2.phone
    c = VCR.use_cassette('NKF Comparison Single Member duplicate user phone',
        match_requests_on: %i[method host path query]) do
      NkfMemberComparison.new(seb).sync
    end
    assert_equal([], c.errors)
    assert_equal [[members(:sebastian), [
      { nkf_attr: :epost, target: :user, target_attribute: :contact_email,
        nkf_value: 'sebastian@example.net', mapped_nkf_value: 'sebastian@example.net',
        rjjk_value: 'sebastian@example.com', mapped_rjjk_value: 'sebastian@example.com',
        form_field: { member: :frm_48_v10, new_trial: :frm_29_v10, trial: :frm_28_v24 } },
      { nkf_attr: :epost_faktura, target: :billing, target_attribute: :email,
        nkf_value: 'lise@example.net', mapped_nkf_value: 'lise@example.net',
        rjjk_value: nil, mapped_rjjk_value: '',
        form_field: { member: :frm_48_v22, new_trial: :frm_29_v22, trial: :frm_28_v25 } },
      { nkf_attr: :fodselsdato, target: :user, target_attribute: :birthdate, nkf_value: '04.06.2004',
        mapped_nkf_value: Date.parse('Fri, 04 Jun 2004'), rjjk_value: Date.parse('Thu, 03 Jun 2004'),
        mapped_rjjk_value: '03.06.2004',
        form_field: { member: :frm_48_v08, new_trial: :frm_29_v08, trial: :frm_28_v14 } },
      { nkf_attr: :foresatte_epost, target: :guardian_1, target_attribute: :email, nkf_value: '',
        mapped_nkf_value: nil, rjjk_value: 'lise@example.com',
        mapped_rjjk_value: 'lise@example.com',
        form_field: { member: :frm_48_v73, new_trial: :frm_29_v73, trial: :frm_a28_v73 } },
      { nkf_attr: :foresatte_nr_2, target: :guardian_2, target_attribute: :name, nkf_value: '',
        mapped_nkf_value: nil, rjjk_value: 'Uwe Kubosch', mapped_rjjk_value: 'Uwe Kubosch',
        form_field: { member: :frm_48_v72, new_trial: :frm_29_v72, trial: :frm_a28_v72 } },
      { nkf_attr: :gren_stilart_avd_parti___gren_stilart_avd_parti, target: :membership,
        target_attribute: :martial_art_name,
        nkf_value: 'Jujutsu/Jujutsu (Ingen stilartstilknytning)/Strømmen Storsenter/Tiger',
        mapped_nkf_value: 'Jujutsu/Jujutsu (Ingen stilartstilknytning)/Strømmen Storsenter/Tiger',
        rjjk_value: 'Kei Wa Ryu', mapped_rjjk_value: 'Jujutsu (Ingen stilartstilknytning)',
        form_field: { new_trial: :frm_29_v16, trial: :frm_28_v28 } },
      { nkf_attr: :innmeldtdato, target: :membership, target_attribute: :joined_on,
        nkf_value: '21.09.2007', mapped_nkf_value: Date.parse('Fri, 21 Sep 2007'),
        rjjk_value: Date.parse('Sat, 25 Aug 2007'), mapped_rjjk_value: '25.08.2007',
        form_field: { member: :frm_48_v45, trial: :frm_28_v64 } },
      { nkf_attr: :kjonn, target: :user, target_attribute: :male, nkf_value: 'Mann',
        mapped_nkf_value: true, rjjk_value: true, mapped_rjjk_value: 'M',
        form_field: { member: :frm_48_v112, new_trial: :frm_29_v11, trial: :frm_28_v15 } },
      { nkf_attr: :kont_sats, target: :membership, target_attribute: :category, nkf_value: 'Passiv sats',
        mapped_nkf_value: 'Passiv sats', rjjk_value: 'Barn', mapped_rjjk_value: 'Barn',
        form_field: { member: :frm_48_v36, trial: :frm_28_v34 } },
      { nkf_attr: :kontraktstype, target: :membership, target_attribute: :contract,
        nkf_value: 'Passiv - Ungdom', mapped_nkf_value: 'Passiv - Ungdom', rjjk_value: 'Barn - familie',
        mapped_rjjk_value: 'Barn - familie', form_field: { member: :frm_48_v37, trial: :frm_28_v36 } },
      { nkf_attr: :medlemskategori_navn, target: :membership, target_attribute: :category,
        nkf_value: 'Passiv', mapped_nkf_value: 'Passiv', rjjk_value: 'Barn', mapped_rjjk_value: 'Barn',
        form_field: { member: :frm_48_v48, trial: :frm_28_v17 } },
      { nkf_attr: :mobil, target: :user, target_attribute: :phone, nkf_value: '92929292',
        mapped_nkf_value: '92929292', rjjk_value: nil, mapped_rjjk_value: '',
        form_field: { member: :frm_48_v20, new_trial: :frm_29_v20, trial: :frm_28_v22 } },
      { nkf_attr: :rabatt, target: :membership, target_attribute: :discount, nkf_value: nil,
        mapped_nkf_value: nil, rjjk_value: 100, mapped_rjjk_value: '100',
        form_field: { member: :frm_48_v38, trial: :frm_28_v35 } },
    ]]], c.members

    assert_equal([
      [seb, {
        { user: :contact_email } => { 'sebastian@kubosch.no' => 'sebastian@example.com' },
        { billing: :email } => { 'lise@kubosch.no' => '' },
        { user: :birthdate } => { '03.06.2004' => '03.06.2004' },
        { guardian_1: :email } => { 'lise@kubosch.no' => 'lise@example.com' },
        { guardian_2: :name } => { 'Uwe Kubosch' => 'Uwe Kubosch' },
        { membership: :joined_on } => { '21.09.2010' => '25.08.2007' },
        { user: :male } => { 'M' => 'M' },
        { membership: :category } => { nil => 'Barn' },
        { membership: :contract } => { nil => 'Barn - familie' },
        { membership: :discount } => { '' => '100' },
      }],
    ], c.outgoing_changes)

    assert_equal [nkf_members(:erik).member], c.new_members
    assert_equal([members(:leftie), members(:newbie), members(:oldie)], c.orphan_members)
    assert_equal([nkf_members(:erik)], c.orphan_nkf_members)
  end
end
