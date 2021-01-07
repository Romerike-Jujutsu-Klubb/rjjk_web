# frozen_string_literal: true

require 'test_helper'

class SignupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @signup = signups(:one)
    login
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
    signups(:three).really_destroy!
    assert_difference('Signup.count') do
      post signups_url, params: { signup: { user_id: id(:sandra) } }
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
    patch signup_url(@signup), params: { signup: { user_id: id(:sandra) } }
    assert_redirected_to signups_url
  end

  test 'should destroy signup' do
    assert_difference('Signup.count', -1) do
      delete signup_url(@signup)
    end

    assert_redirected_to signups_url
  end

  test 'should complete signup' do
    assert_difference('Signup.count', -1) do
      assert_difference('Member.count') do
        assert_no_difference('User.count') do
          patch complete_signup_url(@signup)
        end
      end
    end
    assert_redirected_to signups_url
  end

  test 'should terminate signup' do
    assert_difference('Signup.count', -1) do
      assert_no_difference('Member.count') do
        assert_no_difference('User.count') do
          delete terminate_signup_url(@signup)
        end
      end
    end

    assert_redirected_to signups_url
  end
end
