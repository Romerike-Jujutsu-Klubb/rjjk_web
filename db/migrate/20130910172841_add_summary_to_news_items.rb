# frozen_string_literal: true

class AddSummaryToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :summary, :text
  end
end
