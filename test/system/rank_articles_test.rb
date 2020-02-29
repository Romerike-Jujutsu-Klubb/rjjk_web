# frozen_string_literal: true

require 'application_system_test_case'

class RankArticlesTest < ApplicationSystemTestCase
  setup do
    @rank_article = rank_articles(:one)
    login
  end

  test 'visiting the index' do
    visit rank_articles_url
    assert_selector 'h1', text: 'Rank Articles'
  end

  test 'creating a Rank article' do
    visit rank_articles_url
    click_on 'New Rank article'

    select information_pages(:internal).title, from: 'rank_article_information_page_id'
    select @rank_article.rank.name, from: 'rank_article_rank_id'
    click_on 'Lagre'

    assert_text 'La til artikkel “The secret technique” til grad “5. kyu gult belte”'
  end

  test 'updating a Rank article' do
    visit rank_articles_url
    click_on 'Edit', match: :first

    select @rank_article.information_page.title, from: 'rank_article_information_page_id'
    select @rank_article.rank.name, from: 'rank_article_rank_id'
    click_on 'Lagre'

    assert_text 'Oppdaterte artikkel for grad.'
  end

  test 'destroying a Rank article' do
    visit rank_articles_url
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Slettet artikkel for denne graden.'
  end
end
