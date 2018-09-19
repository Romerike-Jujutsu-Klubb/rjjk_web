# frozen_string_literal: true

class AddSummaryToNewsItems < ActiveRecord::Migration[4.2]
  def change
    add_column :news_items, :summary, :text
  end
end
