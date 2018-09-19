# frozen_string_literal: true

class CreateEmbus < ActiveRecord::Migration[4.2]
  def change
    create_table :embus do |t|
      t.integer :user_id, null: false
      t.integer :rank_id, null: false
      t.text :description, null: false

      t.timestamps
    end
  end
end
