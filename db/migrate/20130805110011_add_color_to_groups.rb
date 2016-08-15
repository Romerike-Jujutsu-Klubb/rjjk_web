class AddColorToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :color, :string, limit: 16
  end
end
