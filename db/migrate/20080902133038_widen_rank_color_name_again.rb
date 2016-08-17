class WidenRankColorNameAgain < ActiveRecord::Migration
  def self.up
    change_column :ranks, :colour, :string, limit: 48, null: false
  end

  def self.down
    change_column :ranks, :colour, :string, limit: 32, null: false
  end
end
