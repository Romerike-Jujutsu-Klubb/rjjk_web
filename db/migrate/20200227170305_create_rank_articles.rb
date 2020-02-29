# frozen_string_literal: true

class CreateRankArticles < ActiveRecord::Migration[6.0]
  def change
    create_table :rank_articles do |t|
      t.integer :position, null: false
      t.references :rank, null: false, foreign_key: true
      t.references :information_page, null: false, foreign_key: true

      t.timestamps
    end
  end
end
