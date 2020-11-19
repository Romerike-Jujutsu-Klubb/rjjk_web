# frozen_string_literal: true

require 'application_system_test_case'

# New user under 18 years with one guardian
# New user under 18 years with one guardian with existing user by phone

# Logged in user "Bli medlem"
# Existing user over 18 years
# Existing user under 18 years

# New user with email in use by ward

# New user under 18 years with two guardians

# New user under 18 years with two guardians and a separate billing user

class SignupGuideTest < ApplicationSystemTestCase
  test 'New user over 18 years' do
    visit root_path
    click_on 'Prøv oss!'

    screenshot :basics
    fill_in :user_name, with: 'Bruce Lee'
    fill_in :user_birthdate, with: '27111940'
    find('label', text: 'Mann').click
    screenshot :basics_filled
    click_on 'Neste'

    screenshot :contact_info
    fill_in :user_email, with: 'bruce.lee@test.com'
    fill_in :user_phone, with: '+1 206 322 1582'
    fill_in :user_address, with: '1554 15th Ave E, Seattle, WA 98112-2805'
    fill_in :user_postal_code, with: '2805'
    screenshot :contact_info_filled
    click_on 'Neste'

    screenshot :groups
    find('label', text: 'Rogue-fu (42-99 år)').click
    screenshot :groups_filled

    assert_difference(-> { Signup.count }, 13) do
      assert_difference(-> { User.count }, 32) do
        assert_difference(-> { NkfMemberTrial.count }, 12) do
          VCR.use_cassette('NKF_Create_Trial', match_requests_on: %i[method host path query]) do
            click_on 'Meld inn'
          end
        end
      end
    end

    screenshot :complete
  end

  test 'New user under 18 years' do
    visit signup_guide_root_path

    screenshot :basics
    fill_in :user_name, with: 'Brendon Lee'
    fill_in :user_birthdate, with: '01022003'
    find('label', text: 'Kvinne').click
    screenshot :basics_filled
    click_on 'Neste'

    screenshot :guardian
    fill_in :user_guardian_1_attributes_phone, with: '+1 206 322 1582'
    fill_in :user_guardian_1_attributes_email, with: 'bruce.lee@test.com'
    fill_in :user_guardian_1_attributes_name, with: 'Bruce Lee'
    fill_in :user_guardian_1_attributes_birthdate, with: '27111940'
    find('label', text: 'Mann').click
    fill_in :user_guardian_1_attributes_address, with: '1554 15th Ave E, Seattle, WA 98112-2805'
    fill_in :user_guardian_1_attributes_postal_code, with: '2805'
    screenshot :guardian_filled
    click_on 'Neste'

    screenshot :contact_info
    screenshot :contact_info_filled
    click_on 'Neste'

    screenshot :groups
    screenshot :groups_filled

    assert_difference(-> { Signup.count }, 13) do
      assert_difference(-> { User.count }, 33) do
        assert_difference(-> { NkfMemberTrial.count }, 12) do
          VCR.use_cassette('NKF_Create_Trial', match_requests_on: %i[method host path query]) do
            click_on 'Meld inn'
          end
        end
      end
    end

    screenshot :complete
  end

  test 'New user under 18 years with one guardian with existing user by email' do
    visit signup_guide_root_path

    screenshot :basics
    fill_in :user_name, with: 'Brendon Lee'
    fill_in :user_birthdate, with: '01022003'
    find('label', text: 'Kvinne').click
    screenshot :basics_filled
    click_on 'Neste'

    screenshot :guardian
    fill_in :user_guardian_1_attributes_phone, with: '+1 206 322 1582'
    fill_in :user_guardian_1_attributes_email, with: 'bruce.lee@test.com'
    fill_in :user_guardian_1_attributes_name, with: 'Bruce Lee'
    fill_in :user_guardian_1_attributes_birthdate, with: '27111940'
    find('label', text: 'Mann').click
    fill_in :user_guardian_1_attributes_address, with: '1554 15th Ave E, Seattle, WA 98112-2805'
    fill_in :user_guardian_1_attributes_postal_code, with: '2805'
    screenshot :guardian_filled
    click_on 'Neste'

    screenshot :contact_info
    screenshot :contact_info_filled
    click_on 'Neste'

    screenshot :groups
    screenshot :groups_filled

    assert_difference(-> { Signup.count }, 13) do
      assert_difference(-> { User.count }, 33) do
        assert_difference(-> { NkfMemberTrial.count }, 12) do
          VCR.use_cassette('NKF_Create_Trial', match_requests_on: %i[method host path query]) do
            click_on 'Meld inn'
          end
        end
      end
    end

    screenshot :complete
  end
end
