# frozen_string_literal: true

require 'test_helper'

class EmbuPartVideosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @embu_part_video = embu_part_videos(:one)
    login
  end

  test 'should get index' do
    get embu_part_videos_url
    assert_response :success
  end

  test 'should get new' do
    get new_embu_part_video_url
    assert_response :success
  end

  test 'should create embu_part_video' do
    assert_difference('EmbuPartVideo.count') do
      post embu_part_videos_url, params: { embu_part_video: {
        comment: @embu_part_video.comment, embu_part_id: @embu_part_video.embu_part_id,
        image_id: @embu_part_video.image_id
      } }
    end

    assert_redirected_to embu_part_video_url(EmbuPartVideo.last)
  end

  test 'should show embu_part_video' do
    get embu_part_video_url(@embu_part_video)
    assert_response :success
  end

  test 'should get edit' do
    get edit_embu_part_video_url(@embu_part_video)
    assert_response :success
  end

  test 'should update embu_part_video' do
    patch embu_part_video_url(@embu_part_video), params: { embu_part_video: {
      comment: @embu_part_video.comment, embu_part_id: @embu_part_video.embu_part_id,
      image_id: @embu_part_video.image_id
    } }
    assert_redirected_to embu_part_video_url(@embu_part_video)
  end

  test 'should destroy embu_part_video' do
    assert_difference('EmbuPartVideo.count', -1) do
      delete embu_part_video_url(@embu_part_video)
    end

    assert_redirected_to embu_part_videos_url
  end
end
