# frozen_string_literal: true

class AddKidToMembers < ActiveRecord::Migration[4.2]
  def self.up
    add_column :members, :kid, :string, limit: 64
  end

  def self.down
    remove_column :members, :kid
  end
end
