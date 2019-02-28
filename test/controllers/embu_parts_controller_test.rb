# frozen_string_literal: true

require 'test_helper'

class EmbuPartsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @embu_part = embu_parts(:one)
    login
  end

  test 'should get index' do
    get embu_parts_url
    assert_response :success
  end

  test 'should get new' do
    get new_embu_part_url
    assert_response :success
  end

  test 'should create embu_part' do
    assert_difference('EmbuPart.count') do
      post embu_parts_url, params: { embu_part: {
        description: @embu_part.description, embu_id: @embu_part.embu_id, position: @embu_part.position
      } }
    end

    assert_redirected_to embu_part_url(EmbuPart.last)
  end

  test 'should show embu_part' do
    get embu_part_url(@embu_part)
    assert_response :success
  end

  test 'should get edit' do
    get edit_embu_part_url(@embu_part)
    assert_response :success
  end

  test 'should update embu_part' do
    patch embu_part_url(@embu_part), params: { embu_part: {
      description: @embu_part.description, embu_id: @embu_part.embu_id, position: @embu_part.position
    } }
    assert_redirected_to embu_part_url(@embu_part)
  end

  test 'should destroy embu_part' do
    assert_difference('EmbuPart.count', -1) do
      delete embu_part_url(@embu_part)
    end

    assert_redirected_to embu_parts_url
  end
end
