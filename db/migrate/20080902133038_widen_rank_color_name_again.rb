# frozen_string_literal: true

class WidenRankColorNameAgain < ActiveRecord::Migration[4.2]
  def self.up
    change_column :ranks, :colour, :string, limit: 48, null: false
  end

  def self.down
    change_column :ranks, :colour, :string, limit: 32, null: false
  end
end
