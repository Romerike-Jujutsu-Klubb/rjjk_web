class AddPlanningToGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :groups, :planning, :boolean
  end
end
