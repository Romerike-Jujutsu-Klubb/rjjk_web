# frozen_string_literal: true

class MakeTrialAttendancesReferencePractices < ActiveRecord::Migration
  def up
    add_index :attendances, %i[member_id practice_id], unique: true

    add_column :trial_attendances, :practice_id, :integer

    execute 'UPDATE trial_attendances a SET practice_id =
      (SELECT id FROM practices s
       WHERE s.group_schedule_id = a.group_schedule_id
         AND s.year = a.year
         AND s.week = a.week
      )'
    change_column :trial_attendances, :practice_id, :integer, null: false
    add_index :trial_attendances, %i[nkf_member_trial_id practice_id], unique: true

    remove_column :trial_attendances, :group_schedule_id
    remove_column :trial_attendances, :year
    remove_column :trial_attendances, :week
  end

  def down; end
end
