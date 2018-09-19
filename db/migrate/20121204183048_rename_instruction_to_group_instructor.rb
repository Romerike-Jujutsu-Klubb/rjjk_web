# frozen_string_literal: true

class RenameInstructionToGroupInstructor < ActiveRecord::Migration[4.2]
  def up
    rename_table :instructions, :group_instructors
  end

  def down
    rename_table :group_instructors, :instructions
  end
end
