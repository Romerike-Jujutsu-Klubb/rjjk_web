# frozen_string_literal: true

class CreateAttendances < ActiveRecord::Migration
  def self.up
    create_table :attendances, force: true do |t|
      t.integer :member_id, null: false
      t.integer :group_schedule_id, null: false
      t.integer :year, null: false
      t.integer :week, null: false
      t.timestamps
    end
    add_index :attendances, %i[member_id group_schedule_id year week],
        unique: true,
        name: 'ix_attendances_on_member_id_et_group_schedule_id_et_year_et_wee'
  end

  def self.down
    drop_table :attendances
  end
end
