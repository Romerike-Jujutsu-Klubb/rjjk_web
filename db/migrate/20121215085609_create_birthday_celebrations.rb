# frozen_string_literal: true
class CreateBirthdayCelebrations < ActiveRecord::Migration
  def change
    create_table :birthday_celebrations do |t|
      t.date :held_on, null: false
      t.text :participants, null: false
      t.integer :sensor1_id, references: :members
      t.integer :sensor2_id, references: :members
      t.integer :sensor3_id, references: :members

      t.timestamps
    end
  end
end
