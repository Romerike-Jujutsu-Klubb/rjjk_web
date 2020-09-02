# frozen_string_literal: true

require 'test_helper'

class SignupControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get signup_index_url
    assert_response :success
  end

  test 'should get basics' do
    get signup_basics_url
    assert_response :success
  end

  test 'should get guardians' do
    get signup_guardians_url
    assert_response :success
  end

  test 'should get complete' do
    get signup_complete_url
    assert_response :success
  end
end
