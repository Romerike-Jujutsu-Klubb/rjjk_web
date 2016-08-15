class AddRoleToGroupInstructor < ActiveRecord::Migration
  def up
    add_column :group_instructors, :role, :string, limit: 16
    execute "UPDATE group_instructors SET role = 'Instruktør'"
    change_column_null :group_instructors, :role, false
  end

  def down
    remove_column :group_instructors, :role
  end
end
