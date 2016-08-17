# frozen_string_literal: true
class AddGroupIdToRanks < ActiveRecord::Migration
  def self.up
    add_column :ranks, :group_id, :integer
    Rank.reset_column_information
    g = Group.find_by_name('Tiger')
    Rank.all.each do |r|
      r.update_attributes! group_id: g.id
    end
    change_column :ranks, :group_id, :integer, null: false
  end

  def self.down
    remove_column :ranks, :group_id
  end
end
