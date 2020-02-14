# frozen_string_literal: true

require 'test_helper'

class CurriculumsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @curriculum = curriculum_groups(:voksne)
    login
  end

  test 'should get index' do
    get curriculums_url
    assert_response :success
  end

  test 'should get new' do
    get new_curriculum_url
    assert_response :success
  end

  test 'should create curriculum' do
    assert_difference('CurriculumGroup.count') do
      post curriculums_url, params: { curriculum: {
        color: @curriculum.color, from_age: @curriculum.from_age,
        martial_art_id: @curriculum.martial_art_id, name: @curriculum.name, position: @curriculum.position,
        to_age: @curriculum.to_age
      } }
    end

    assert_redirected_to curriculum_url(CurriculumGroup.last)
  end

  test 'should show curriculum' do
    get curriculum_url(@curriculum)
    assert_response :success
  end

  test 'should get edit' do
    get edit_curriculum_url(@curriculum)
    assert_response :success
  end

  test 'should update curriculum' do
    patch curriculum_url(@curriculum), params: { curriculum: {
      color: @curriculum.color, from_age: @curriculum.from_age,
      martial_art_id: @curriculum.martial_art_id, name: @curriculum.name, position: @curriculum.position,
      to_age: @curriculum.to_age
    } }
    assert_redirected_to curriculum_url(@curriculum)
  end

  test 'should not destroy curriculum with dependent practice groups' do
    assert_no_difference('CurriculumGroup.count', -1) { delete curriculum_url(@curriculum) }
    assert_redirected_to curriculums_url
  end

  test 'should destroy curriculum' do
    groups(:voksne).update!(curriculum_group: curriculum_groups(:voksne_aikido))
    groups(:closed).update!(curriculum_group: curriculum_groups(:voksne_aikido))
    assert_difference('CurriculumGroup.count', -1) { delete curriculum_url(@curriculum) }
    assert_redirected_to curriculums_url
  end
end
