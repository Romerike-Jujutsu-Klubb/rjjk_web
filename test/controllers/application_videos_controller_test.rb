# frozen_string_literal: true

require 'test_helper'

class ApplicationVideosControllerTest < ActionDispatch::IntegrationTest
  setup do
    login
    @application_video = application_videos(:one)
  end

  test 'should get index' do
    get application_videos_url
    assert_response :success
  end

  test 'should get new' do
    get new_application_video_url
    assert_response :success
  end

  test 'should create application_video' do
    assert_difference('ApplicationVideo.count') do
      post application_videos_url, params: { application_video: {
        image_id: @application_video.image_id,
        technique_application_id: @application_video.technique_application_id,
      } }
    end

    assert_redirected_to application_video_url(ApplicationVideo.last)
  end

  test 'should show application_video' do
    get application_video_url(@application_video)
    assert_response :success
  end

  test 'should get edit' do
    get edit_application_video_url(@application_video)
    assert_response :success
  end

  test 'should update application_video' do
    patch application_video_url(@application_video), params: { application_video: {
      image_id: @application_video.image_id,
      technique_application_id: @application_video.technique_application_id,
    } }
    assert_redirected_to application_video_url(@application_video)
  end

  test 'should destroy application_video' do
    assert_difference('ApplicationVideo.count', -1) do
      delete application_video_url(@application_video)
    end

    assert_redirected_to application_videos_url
  end
end
