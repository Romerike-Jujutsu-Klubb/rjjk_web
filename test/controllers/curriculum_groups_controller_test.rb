# frozen_string_literal: true

require 'test_helper'

class CurriculumGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @curriculum_group = curriculum_groups(:voksne)
    login
  end

  test 'should get index' do
    get curriculum_groups_url
    assert_response :success
  end

  test 'should get new' do
    get new_curriculum_group_url
    assert_response :success
  end

  test 'should create curriculum_group' do
    assert_difference('CurriculumGroup.count') do
      post curriculum_groups_url, params: { curriculum_group: {
        color: @curriculum_group.color, from_age: @curriculum_group.from_age,
        martial_art_id: @curriculum_group.martial_art_id, name: @curriculum_group.name,
        position: @curriculum_group.position, to_age: @curriculum_group.to_age
      } }
    end

    assert_redirected_to curriculum_group_url(CurriculumGroup.last)
  end

  test 'should show curriculum_group' do
    get curriculum_group_url(@curriculum_group)
    assert_response :success
  end

  test 'should get edit' do
    get edit_curriculum_group_url(@curriculum_group)
    assert_response :success
  end

  test 'should update curriculum_group' do
    patch curriculum_group_url(@curriculum_group), params: { curriculum_group: {
      color: @curriculum_group.color, from_age: @curriculum_group.from_age,
      martial_art_id: @curriculum_group.martial_art_id, name: @curriculum_group.name,
      position: @curriculum_group.position, to_age: @curriculum_group.to_age
    } }
    assert_redirected_to curriculum_group_url(@curriculum_group)
  end

  test 'should destroy curriculum_group' do
    groups(:voksne).update!(curriculum_group: curriculum_groups(:voksne_aikido))
    groups(:closed).update!(curriculum_group: curriculum_groups(:voksne_aikido))
    assert_difference('CurriculumGroup.count', -1) { delete curriculum_group_url(@curriculum_group) }
    assert_redirected_to curriculum_groups_url
  end
end
