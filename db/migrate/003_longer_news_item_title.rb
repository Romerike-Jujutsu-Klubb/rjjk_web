# frozen_string_literal: true

class LongerNewsItemTitle < ActiveRecord::Migration[4.2]
  def self.up
    change_column :news_items, 'title', :string, limit: 64, null: false
  end

  def self.down; end
end
