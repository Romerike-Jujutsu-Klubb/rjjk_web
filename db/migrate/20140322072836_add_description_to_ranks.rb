class AddDescriptionToRanks < ActiveRecord::Migration
  def change
    add_column :ranks, :description, :text
  end
end
