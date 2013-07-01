class LinkGroupInstructorToGroupSemester < ActiveRecord::Migration
  def up
    execute 'DELETE FROM group_instructors'
    add_column :group_instructors, :semester_id, :integer, :null => false
    remove_column :group_instructors, :from
    remove_column :group_instructors, :to
  end

  def down
    add_column :group_instructors, :to, :date
    add_column :group_instructors, :from, :date
    add_column :group_instructors, :group_schedule_id, :integer, :null => false
    remove_column :group_instructors, :semester_id
  end
end
