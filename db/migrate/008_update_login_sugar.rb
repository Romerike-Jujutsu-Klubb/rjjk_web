class UpdateLoginSugar < ActiveRecord::Migration
  def self.up
      add_column :users, :verified_tmp, :boolean, :default => false
      add_column :users, :deleted_tmp, :boolean, :default => false

      User.all.each { |u| User.update(u.id, :verified_tmp => u.verified == 1) }
      User.all.each { |u| User.update(u.id, :deleted_tmp => u.deleted == 1) }

      remove_column :users, :verified
      rename_column :users, :verified_tmp, :verified

      remove_column :users, :deleted
      rename_column :users, :deleted_tmp, :deleted

      remove_column :users, :delete_after
  end

  def self.down
      add_column :users, :delete_after, :datetime, :default => nil

      add_column :users, :verified_tmp, :integer, :default => 0
      add_column :users, :deleted_tmp, :integer, :default => 0

      User.all.each { |u| User.update(u.id, :verified_tmp => u.verified ? 1 : 0) }
      User.all.each { |u| User.update(u.id, :deleted_tmp => u.deleted ? 1 : 0) }

      remove_column :users, :verified
      rename_column :users, :verified_tmp, :verified

      remove_column :users, :deleted
      rename_column :users, :deleted_tmp, :deleted
  end

  class User < ActiveRecord::Base; end
end
