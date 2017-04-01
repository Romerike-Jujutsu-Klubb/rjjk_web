# frozen_string_literal: true

class AddExpiresAtToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :publish_at, :datetime
    add_column :news_items, :expire_at, :datetime
  end
end
