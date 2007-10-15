class UpdateLoginSugar < ActiveRecord::Migration
  def self.up
      add_column :users, :verified_tmp, :boolean, :default => false
      execute('UPDATE users SET verified_tmp = true WHERE verified = 1')
      execute('UPDATE users SET verified_tmp = false WHERE verified = 0')
      remove_column :users, :verified
      rename_column :users, :verified_tmp, :verified

      add_column :users, :deleted_tmp, :boolean, :default => false
      execute('UPDATE users SET deleted_tmp = true WHERE deleted = 1')
      execute('UPDATE users SET deleted_tmp = false WHERE deleted = 0')
      remove_column :users, :deleted
      rename_column :users, :deleted_tmp, :deleted

      remove_column :users, :delete_after
  end

  def self.down
      add_column :users, :delete_after, :datetime, :default => nil
      change_column :users, :deleted, :integer, :default => 0
      change_column :users, :verified, :integer, :default => 0
  end
end
