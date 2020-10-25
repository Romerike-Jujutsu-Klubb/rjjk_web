# frozen_string_literal: true

require 'application_system_test_case'

# New user over 18 years
# New user under 18 years with one guardian

# Logged in user "Bli medlem"
# Existing user over 18 years
# Existing user under 18 years

# New user with email in use by ward

# New user under 18 years with two guardians

# New user under 18 years with two guardians and a separate billing user

class SignupGuideTest < ApplicationSystemTestCase
  setup do
    @signup = signups(:one)
    login
  end

  test 'visiting the index' do
    visit signups_url
    assert_selector 'h1', text: 'Innmeldinger'
  end

  test 'creating a Signup' do
    signups(:three).delete
    visit signups_url
    click_on 'Ny innmelding'
    assert_current_path signup_guide_root_path
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
