class AddCreatedByToNewsItem < ActiveRecord::Migration
  def self.up
    add_column :news_items, :created_by, :integer, references: :users
  end

  def self.down
    remove_column :news_items, :created_by
  end
end
