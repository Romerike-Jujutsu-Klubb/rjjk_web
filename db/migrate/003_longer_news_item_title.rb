class LongerNewsItemTitle < ActiveRecord::Migration
  def self.up
    change_column :news_items, "title", :string, :limit => 64, :null => false
  end

  def self.down
  end
end
