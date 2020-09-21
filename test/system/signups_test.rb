# frozen_string_literal: true

require 'application_system_test_case'

class SignupsTest < ApplicationSystemTestCase
  setup do
    @signup = signups(:one)
    login
  end

  test 'visiting the index' do
    visit signups_url
    assert_selector 'h1', text: 'Prøvemedlemskap'
  end

  test 'creating a Signup' do
    visit signups_url
    click_on 'Nytt prøvemedlemskap'
    assert_current_path new_signup_path

    select_from_chosen 'Even Jensen', from: :signup_nkf_member_trial_id
    select_from_chosen 'Deletable', from: :signup_user_id
    click_on 'Lagre'

    assert_text 'Signup was successfully created'
  end

  test 'updating a Signup' do
    visit signups_url
    first('tbody tr').click
    click_on 'Endre'

    select_from_chosen 'Hans Eriksen', from: :signup_nkf_member_trial_id
    select_from_chosen 'Lise Kubosch', from: :signup_user_id
    click_on 'Lagre'

    assert_text 'Signup was successfully updated'
  end

  test 'destroying a Signup' do
    visit signups_url
    first('tbody tr').click
    click_on 'Endre'
    page.accept_confirm do
      click_on 'Slett'
    end

    assert_text 'Signup was successfully destroyed'
  end
end
