# frozen_string_literal: true

class AddRfid < ActiveRecord::Migration[4.2]
  def self.up
    add_column :members, :rfid, :string, limit: 25
  end

  def self.down
    remove_column :members, :rfid
  end
end
