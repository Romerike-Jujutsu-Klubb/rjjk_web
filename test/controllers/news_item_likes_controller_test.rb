# frozen_string_literal: true

require 'integration_test'

class NewsItemLikesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @news_item_like = news_item_likes(:one)
  end

  test 'should get index' do
    get news_item_likes_url
    assert_response :success
  end

  test 'should get new' do
    get new_news_item_like_url
    assert_response :success
  end

  test 'should create news_item_like' do
    assert_difference('NewsItemLike.count') do
      post news_item_likes_url, params: { news_item_like: {
          news_item_id: @news_item_like.news_item_id, user_id: @news_item_like.user_id
      } }
    end

    assert_redirected_to news_item_like_url(NewsItemLike.last)
  end

  test 'should show news_item_like' do
    get news_item_like_url(@news_item_like)
    assert_response :success
  end

  test 'should get edit' do
    get edit_news_item_like_url(@news_item_like)
    assert_response :success
  end

  test 'should update news_item_like' do
    patch news_item_like_url(@news_item_like), params: { news_item_like: {
        news_item_id: @news_item_like.news_item_id, user_id: @news_item_like.user_id
    } }
    assert_redirected_to news_item_like_url(@news_item_like)
  end

  test 'should destroy news_item_like' do
    assert_difference('NewsItemLike.count', -1) do
      delete news_item_like_url(@news_item_like)
    end

    assert_redirected_to news_item_likes_url
  end
end
