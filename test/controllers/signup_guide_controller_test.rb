# frozen_string_literal: true

require 'test_helper'

class SignupGuideControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get signup_guide_root_url
    assert_response :success
  end

  test 'post contact_info' do
    post signup_guide_contact_info_url, params: { user: { birthdate: '2004-06-03' } }
    assert_redirected_to signup_guide_groups_path
  end

  test 'post guardians' do
    post signup_guide_guardians_url
    assert_redirected_to signup_guide_contact_info_path
  end

  test 'post complete' do
    VCR.use_cassette 'register_nkf_trial' do
      post signup_guide_groups_path params: { user: {
        address: 'Nyveien 5',
        birthdate: '1999-12-31',
        email: 'ny@test.org',
      } }
      assert_response :success
    end
  end
end
