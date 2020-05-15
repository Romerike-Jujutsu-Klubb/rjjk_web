# frozen_string_literal: true

require 'test_helper'

class CurriculumsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @curriculum = curriculum_groups(:voksne)
    login(:newbie)
  end

  test 'should get index' do
    get curriculums_url
    assert_redirected_to curriculum_group_path(id(:voksne))
  end

  test 'should get index as admin' do
    login
    get curriculums_url
    assert_response :success
  end

  test 'should show curriculum' do
    get curriculum_url(@curriculum)
    assert_redirected_to curriculum_group_path(id(:voksne))
  end

  test 'should get card as plain member' do
    login :newbie
    get card_pdf_curriculums_path(@curriculum)
    assert_response :success
  end
end
