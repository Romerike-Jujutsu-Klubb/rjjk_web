class CreateElections < ActiveRecord::Migration
  def change
    create_table :elections do |t|
      t.integer :annual_meeting_id, null: false
      t.integer :member_id, null: false
      t.integer :role_id, null: false
      t.integer :years, null: false
      t.date :resigned_on

      t.timestamps
    end
  end
end
