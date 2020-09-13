# frozen_string_literal: true

class AddPublicToNewsItems < ActiveRecord::Migration[6.0]
  def change
    add_column :news_items, :user_selection, :boolean
  end
end
