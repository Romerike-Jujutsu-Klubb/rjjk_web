# frozen_string_literal: true

require 'application_system_test_case'

class RankArticlesTest < ApplicationSystemTestCase
  setup do
    @rank_article = rank_articles(:one)
  end

  test 'visiting the index' do
    visit rank_articles_url
    assert_selector 'h1', text: 'Rank Articles'
  end

  test 'creating a Rank article' do
    visit rank_articles_url
    click_on 'New Rank article'

    select @rank_article.information_page.title, from: 'rank_article_information_page_id'
    select @rank_article.rank.name, from: 'rank_article_rank_id'
    click_on 'Lag Rank article'

    assert_text 'Rank article was successfully created'
    click_on 'Back'
  end

  test 'updating a Rank article' do
    visit rank_articles_url
    click_on 'Edit', match: :first

    select @rank_article.information_page.title, from: 'rank_article_information_page_id'
    select @rank_article.rank.name, from: 'rank_article_rank_id'
    click_on 'Oppdater Rank article'

    assert_text 'Rank article was successfully updated'
    click_on 'Back'
  end

  test 'destroying a Rank article' do
    visit rank_articles_url
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Rank article was successfully destroyed'
  end
end
