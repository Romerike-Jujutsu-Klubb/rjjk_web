class UpdateLoginSugar < ActiveRecord::Migration
  def self.up
      add_column :users, :verified_tmp, :boolean, :default => false
      add_column :users, :deleted_tmp, :boolean, :default => false

      User.find(:all).each{|u| User.update(u.id, :verified_tmp => u.verified == 1)}
      User.find(:all).each{|u| User.update(u.id, :deleted_tmp => u.deleted == 1)}

      remove_column :users, :verified
      rename_column :users, :verified_tmp, :verified

      remove_column :users, :deleted
      rename_column :users, :deleted_tmp, :deleted

      remove_column :users, :delete_after
  end

  def self.down
      add_column :users, :delete_after, :datetime, :default => nil
      change_column :users, :deleted, :integer, :default => 0
      change_column :users, :verified, :integer, :default => 0
  end
  
  class User < ActiveRecord::Base ; end
end
