class UpdateLoginSugar < ActiveRecord::Migration
  def self.up
      change_column :users, :verified, :boolean, :default => false
      change_column :users, :deleted, :boolean, :default => false
      remove_column :users, :delete_after
  end

  def self.down
      add_column :delete_after, :datetime, :default => nil
      change_column :users, :deleted, :integer, :default => 0
      change_column :users, :verified, :integer, :default => 0
  end
end
