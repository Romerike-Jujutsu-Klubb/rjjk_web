class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :name, :limit => 64, :null => false
      t.datetime :start_at, :null => false
      t.datetime :end_at, :null => false
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
