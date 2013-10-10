class AddTargetSizeToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :target_size, :integer
  end
end
