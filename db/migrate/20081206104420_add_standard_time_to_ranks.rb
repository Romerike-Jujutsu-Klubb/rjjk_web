class AddStandardTimeToRanks < ActiveRecord::Migration
  def self.up
    add_column :ranks, :standard_months, :integer, :null => true
    Rank.update_all :standard_months => 6
    change_column :ranks, :standard_months, :integer, :null => false
  end
  
  def self.down
    remove_column :ranks, :standard_months
  end

  class Rank < ActiveRecord::Base ; end
end
