# frozen_string_literal: true

class CreateGroupSemesters < ActiveRecord::Migration
  def change
    create_table :group_semesters do |t|
      t.integer :group_id, null: false
      t.integer :semester_id, null: false
      t.date :first_session
      t.date :last_session

      t.timestamps
    end
    add_column :groups, :school_breaks, :boolean
  end
end
