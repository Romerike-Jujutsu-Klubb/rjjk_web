# frozen_string_literal: true
class AddVentekidToNkfMembers < ActiveRecord::Migration
  def self.up
    add_column :nkf_members, :ventekid, :string, limit: 20
  end

  def self.down
    remove_column :nkf_members, :ventekid
  end
end
