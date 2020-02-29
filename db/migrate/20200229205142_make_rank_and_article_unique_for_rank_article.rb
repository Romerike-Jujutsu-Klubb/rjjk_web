# frozen_string_literal: true

class MakeRankAndArticleUniqueForRankArticle < ActiveRecord::Migration[6.0]
  def change
    add_index :rank_articles, %i[rank_id information_page_id], unique: true
    add_index :rank_articles, %i[rank_id position], unique: true
  end
end
