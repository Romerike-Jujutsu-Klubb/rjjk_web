class CreateAttendances < ActiveRecord::Migration
  def self.up
    create_table :attendances, :force => true do |t|
      t.integer :member_id, :null => false
      t.integer :group_schedule_id, :null => false
      t.integer :year, :null => false
      t.integer :week, :null => false
      t.timestamps
    end
    add_index :attendances, [:member_id, :group_schedule_id, :year, :week], :unique => true
  end
  
end
