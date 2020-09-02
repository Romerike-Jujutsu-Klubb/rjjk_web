# frozen_string_literal: true

require 'test_helper'

class SignupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @signup = signups(:one)
  end

  test 'should get index' do
    get signups_url
    assert_response :success
  end

  test 'should get new' do
    get new_signup_url
    assert_response :success
  end

  test 'should create signup' do
    assert_difference('Signup.count') do
      post signups_url, params: { signup: {
        nkf_member_trial_id: @signup.nkf_member_trial_id, user_id: id(:uwe)
      } }
    end

    assert_redirected_to signups_url
  end

  test 'should show signup' do
    get signup_url(@signup)
    assert_response :success
  end

  test 'should get edit' do
    get edit_signup_url(@signup)
    assert_response :success
  end

  test 'should update signup' do
    patch signup_url(@signup), params: { signup: {
      nkf_member_trial_id: @signup.nkf_member_trial_id, user_id: id(:uwe)
    } }
    assert_redirected_to signups_url
  end

  test 'should destroy signup' do
    assert_difference('Signup.count', -1) do
      delete signup_url(@signup)
    end

    assert_redirected_to signups_url
  end
end
