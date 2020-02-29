# frozen_string_literal: true

require 'test_helper'

class RankArticlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rank_article = rank_articles(:one)
    login
  end

  test 'should get index' do
    get rank_articles_url
    assert_response :success
  end

  test 'should get new' do
    get new_rank_article_url
    assert_response :success
  end

  test 'should create rank_article' do
    assert_difference('RankArticle.count') do
      post rank_articles_url, params: { rank_article: {
        information_page_id: @rank_article.information_page_id, position: @rank_article.position,
        rank_id: @rank_article.rank_id
      } }
    end

    assert_redirected_to edit_rank_path(RankArticle.last.rank)
  end

  test 'should show rank_article' do
    get rank_article_url(@rank_article)
    assert_response :success
  end

  test 'should get edit' do
    get edit_rank_article_url(@rank_article)
    assert_response :success
  end

  test 'should update rank_article' do
    patch rank_article_url(@rank_article), params: { rank_article: {
      information_page_id: @rank_article.information_page_id, position: @rank_article.position,
      rank_id: @rank_article.rank_id
    } }
    assert_redirected_to edit_rank_url(@rank_article.rank)
  end

  test 'should destroy rank_article' do
    assert_difference('RankArticle.count', -1) do
      delete rank_article_url(@rank_article)
    end

    assert_redirected_to rank_articles_url
  end
end
