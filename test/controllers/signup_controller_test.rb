# frozen_string_literal: true

require 'test_helper'

class SignupControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get signup_guide_root_url
    assert_response :success
  end

  test 'should get contact_info' do
    post signup_guide_contact_info_url, params: { user: { birthdate: '2004-06-03' } }
    assert_response :success
  end

  test 'should get guardians' do
    post signup_guide_guardians_url
    assert_response :success
  end

  test 'post complete' do
    VCR.use_cassette 'register_nkf_trial' do
      post signup_guide_complete_url params: { user: { email: 'ny@test.org', birthdate: '1999-12-31' } }
      assert_response :success
      puts response.body
      puts Nokogiri::XML(response.body, &:noblanks)
    end
  end
end
