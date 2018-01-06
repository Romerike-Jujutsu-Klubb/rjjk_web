# frozen_string_literal: true

class LoginSugar < ActiveRecord::Migration
  def self.up
    create_table :users, force: true do |t|
      t.column :login, :string, limit: 80, null: false
      t.column :salted_password, :string, limit: 40, null: false
      t.column :email, :string, limit: 60, null: false
      t.column :first_name, :string, limit: 40
      t.column :last_name, :string, limit: 40
      t.column :salt, 'CHAR(40)', null: false
      t.column :verified, :integer, default: 0
      t.column :role, :string, limit: 40, default: nil
      t.column :security_token, 'CHAR(40)', default: nil
      t.column :token_expiry, :datetime, default: nil
      t.column :deleted, :integer, default: 0
      t.column :delete_after, :datetime, default: nil
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
