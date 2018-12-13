# frozen_string_literal: true

require 'test_helper'

class CurriculumControllerTest < ActionDispatch::IntegrationTest
  test 'index' do
    login(:lars)
    get curriculums_path
    assert_response :success
  end

  test 'index redirects to login for strangers' do
    get curriculums_path
    assert_redirected_to login_path
  end

  test 'index for beginner' do
    login :newbie
    get curriculums_path
    assert_response :success
  end

  test 'card' do
    login(:lars)
    get card_curriculum_path(id(:kyu_5))
    assert_response :success
  end

  test 'card_pdf' do
    login(:lars)
    get card_pdf_curriculums_path
    assert_response :success
  end

  test 'pdf' do
    login(:lars)
    assert_raises Prawn::Errors::UnsupportedImageType do
      get pdf_curriculum_path(id(:kyu_5))
      assert_response :success
    end
  end
end
