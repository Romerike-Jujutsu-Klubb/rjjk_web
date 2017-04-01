# frozen_string_literal: true

class AddMemberFields < ActiveRecord::Migration
  def self.up
    add_column :members, :social_sec_no, :string, limit: 6
    add_column :members, :account_no, :string, limit: 16
    add_column :members, :billing_phone_home, :string, limit: 32
    add_column :members, :billing_phone_mobile, :string, limit: 32
  end

  def self.down
    remove_column :members, :billing_phone_mobile
    remove_column :members, :billing_phone_home
    remove_column :members, :account_no
    remove_column :members, :social_sec_no
  end
end
