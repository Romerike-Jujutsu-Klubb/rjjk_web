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

  test 'should get complete' do
    post signup_guide_complete_url
    assert_response :success
  end
end
