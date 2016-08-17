# frozen_string_literal: true
class CreateSemesters < ActiveRecord::Migration
  def change
    create_table :semesters do |t|
      t.date :start_on, null: false
      t.date :end_on, null: false

      t.timestamps
    end
  end
end
