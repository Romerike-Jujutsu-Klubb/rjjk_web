# frozen_string_literal: true

class MakeKontraktsbelopInteger < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :nkf_members, :kontraktsbelop
    add_column :nkf_members, :kontraktsbelop, :integer
  end

  def self.down
    change_column :nkf_members, :kontraktsbelop, :string
  end
end
