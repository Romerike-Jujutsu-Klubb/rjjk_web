# frozen_string_literal: true

class CreateAppointments < ActiveRecord::Migration[4.2]
  def change
    create_table :appointments do |t|
      t.integer :member_id, null: false
      t.integer :role_id, null: false
      t.date :from, null: false
      t.date :to

      t.timestamps
    end
  end
end
