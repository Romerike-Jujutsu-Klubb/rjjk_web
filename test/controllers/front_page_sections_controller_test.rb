# frozen_string_literal: true

require 'test_helper'

class FrontPageSectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @front_page_section = front_page_sections(:one)
    login
  end

  test 'should get index' do
    get front_page_sections_url
    assert_response :success
  end

  test 'should get new' do
    get new_front_page_section_url
    assert_response :success
  end

  test 'should create front_page_section' do
    assert_difference('FrontPageSection.count') do
      post front_page_sections_url, params: { front_page_section: {
        button_text: @front_page_section.button_text, image_id: @front_page_section.image_id,
        information_page_id: @front_page_section.information_page_id,
        subtitle: @front_page_section.subtitle, title: @front_page_section.title
      } }
    end

    assert_redirected_to front_page_sections_url
  end

  test 'should show front_page_section' do
    get front_page_section_url(@front_page_section)
    assert_response :success
  end

  test 'should get edit' do
    get edit_front_page_section_url(@front_page_section)
    assert_response :success
  end

  test 'should update front_page_section' do
    patch front_page_section_url(@front_page_section), params: { front_page_section: {
      button_text: @front_page_section.button_text, image_id: @front_page_section.image_id,
      information_page_id: @front_page_section.information_page_id,
      subtitle: @front_page_section.subtitle, title: @front_page_section.title
    } }
    assert_redirected_to front_page_section_url(@front_page_section)
  end

  test 'should destroy front_page_section' do
    assert_difference('FrontPageSection.count', -1) do
      delete front_page_section_url(@front_page_section)
    end

    assert_redirected_to front_page_sections_url
  end
end
