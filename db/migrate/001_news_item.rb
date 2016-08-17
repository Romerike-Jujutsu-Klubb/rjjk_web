# frozen_string_literal: true
class NewsItem < ActiveRecord::Migration
  def self.up
    create_table 'news_items' do |t|
      t.column 'title', :string, limit: 32, null: false
      t.column 'body', :text
      t.column 'created_at', :datetime
      t.column 'updated_at', :datetime
    end
    create_table 'information_pages' do |t|
      t.column 'parent_id', :integer
      t.column 'title', :string, limit: 32, null: false
      t.column 'body', :text
      t.column 'created_at', :datetime
      t.column 'updated_at', :datetime
    end
  end

  def self.down
    drop_table 'news_items'
    drop_table 'information_pages'
  end
end
