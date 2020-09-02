# frozen_string_literal: true

require 'application_system_test_case'

class SignupsTest < ApplicationSystemTestCase
  setup do
    @signup = signups(:one)
    login
  end

  test 'visiting the index' do
    visit signups_url
    assert_selector 'h1', text: 'Signups'
  end

  test 'creating a Signup' do
    visit signups_url
    click_on 'New Signup'
    assert_current_path new_signup_path

    select_from_chosen 'Hans Eriksen', from: :signup_nkf_member_trial_id
    select_from_chosen 'Deletable', from: :signup_user_id
    click_on 'Lag Signup'

    assert_text 'Signup was successfully created'
  end

  test 'updating a Signup' do
    visit signups_url
    click_on 'Edit', match: :first

    select_from_chosen 'Hans Eriksen', from: :signup_nkf_member_trial_id
    select_from_chosen 'Deletable', from: :signup_user_id
    click_on 'Oppdater Signup'

    assert_text 'Signup was successfully updated'
  end

  test 'destroying a Signup' do
    visit signups_url
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Signup was successfully destroyed'
  end
end
