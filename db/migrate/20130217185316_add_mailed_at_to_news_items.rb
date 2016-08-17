# frozen_string_literal: true
class AddMailedAtToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :mailed_at, :datetime
  end
end
