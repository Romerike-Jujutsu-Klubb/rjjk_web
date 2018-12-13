# frozen_string_literal: true

require 'test_helper'

class CurriculumControllerTest < ActionDispatch::IntegrationTest
  test 'index' do
    login(:lars)
    get curriculum_path
    assert_response :success
  end

  test 'index redirects to login for strangers' do
    get curriculum_path
    assert_redirected_to login_path
  end

  test 'index for beginner' do
    login :newbie
    get curriculum_path
    assert_response :success
  end

  test 'card' do
    login(:lars)
    get curriculum_card_path
    assert_response :success
  end

  test 'card_pdf' do
    login(:lars)
    get curriculum_card_pdf_path
    assert_response :success
  end

  test 'pdf' do
    login(:lars)
    get curriculum_pdf_path
    assert_response :success
  end
end
