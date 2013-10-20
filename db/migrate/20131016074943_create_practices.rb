class CreatePractices < ActiveRecord::Migration
  def change
    create_table :practices do |t|
      t.integer :group_schedule_id, :null => false
      t.integer :year, :null => false
      t.integer :week, :null => false
      t.string :status, :null => false, :default => 'X'

      t.timestamps
      t.index [:group_schedule_id, :year, :week], :unique => true
    end

    execute 'INSERT INTO practices(group_schedule_id, year, week, created_at, updated_at)
            (SELECT DISTINCT group_schedule_id, year, week, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM attendances)'

    add_column :attendances, :practice_id, :integer
    execute 'UPDATE attendances a SET practice_id =
      (SELECT id FROM practices s
       WHERE s.group_schedule_id = a.group_schedule_id
         AND s.year = a.year
         AND s.week = a.week
      )'
    change_column :attendances, :practice_id, :integer, :null => false

    remove_column :attendances, :group_schedule_id
    remove_column :attendances, :year
    remove_column :attendances, :week
  end
end
