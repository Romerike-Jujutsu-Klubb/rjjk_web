# frozen_string_literal: true

require 'controller_test'

class PracticesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @practice = practices(:panda_2010_42)
    login(:admin)
  end

  test 'should get index' do
    get practices_path
    assert_response :success
  end

  test 'should get new' do
    get new_practice_path
    assert_response :success
  end

  test 'should create practice' do
    assert_difference('Practice.count') do
      post practices_path, params: { practice: {
        status: @practice.status,
        group_schedule_id: @practice.group_schedule_id,
        week: @practice.week + 1, year: @practice.year
      } }
    end

    assert_redirected_to practices_path
  end

  test 'should show practice' do
    get practice_path(@practice)
    assert_response :success
  end

  test 'should get edit' do
    get edit_practice_path(@practice)
    assert_response :success
  end

  test 'should update practice' do
    put practice_path(@practice), params: { practice: {
      status: @practice.status,
      group_schedule_id: @practice.group_schedule_id,
      week: @practice.week, year: @practice.year
    } }
    assert_redirected_to @practice
  end

  test 'should update practice body with xhr' do
    put practice_path(@practice), params: { practice: {
      message: 'Spennende trening med veldig flink instruktør.',
    } }, xhr: true
    assert_response :success
    assert_equal '', response.body
  end

  test 'should destroy practice' do
    assert_difference('Practice.count', -1) do
      delete practice_path(@practice)
    end

    assert_redirected_to practices_path
  end
end
