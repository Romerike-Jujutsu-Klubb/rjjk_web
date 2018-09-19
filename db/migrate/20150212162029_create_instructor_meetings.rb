# frozen_string_literal: true

class CreateInstructorMeetings < ActiveRecord::Migration[4.2]
  def change
    create_table :instructor_meetings do |t|
      t.datetime :start_at, null: false
      t.time :end_at, null: false
      t.string :title, null: false, limit: 254
      t.text :agenda, null: false

      t.timestamps
    end
  end
end
