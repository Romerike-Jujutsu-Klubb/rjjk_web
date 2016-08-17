# frozen_string_literal: true
class AddKidToCmsMembers < ActiveRecord::Migration
  def self.up
    add_column :cms_members, :kid, :string, limit: 64
  end

  def self.down
    remove_column :cms_members, :kid
  end
end
