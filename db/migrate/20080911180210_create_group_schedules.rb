class CreateGroupSchedules < ActiveRecord::Migration
  def self.up
    create_table :group_schedules do |t|
      t.integer :group_id, :null => false
      t.integer :weekday, :null => false
      t.time :start_at, :null => false
      t.time :end_at, :null => false
      
      t.timestamps
    end
    
    GroupSchedule.create! :group_id => 2, :weekday => 2, :start_at => Time.local(2000, 1, 1, 17, 45), :end_at => Time.local(2000, 1, 1, 18, 45)
    GroupSchedule.create! :group_id => 3, :weekday => 2, :start_at => Time.local(2000, 1, 1, 19), :end_at => Time.local(2000, 1, 1, 20, 30)
    GroupSchedule.create! :group_id => 4, :weekday => 2, :start_at => Time.local(2000, 1, 1, 19), :end_at => Time.local(2000, 1, 1, 21)
    GroupSchedule.create! :group_id => 2, :weekday => 4, :start_at => Time.local(2000, 1, 1, 17, 45), :end_at => Time.local(2000, 1, 1, 18, 45)
    GroupSchedule.create! :group_id => 3, :weekday => 4, :start_at => Time.local(2000, 1, 1, 19), :end_at => Time.local(2000, 1, 1, 20, 30)
    GroupSchedule.create! :group_id => 4, :weekday => 4, :start_at => Time.local(2000, 1, 1, 19), :end_at => Time.local(2000, 1, 1, 21)
    GroupSchedule.create! :group_id => 1, :weekday => 5, :start_at => Time.local(2000, 1, 1, 18), :end_at => Time.local(2000, 1, 1, 19)
  end
  
  def self.down
    drop_table :group_schedules
  end
  
  class GroupSchedule < ActiveRecord::Base
    belongs_to :group
  end
  
end
