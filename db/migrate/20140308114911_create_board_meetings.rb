# frozen_string_literal: true
class CreateBoardMeetings < ActiveRecord::Migration
  def change
    create_table :board_meetings do |t|
      t.datetime :start_at, null: false
      t.string :minutes_filename, limit: 64
      t.string :minutes_content_type, limit: 32
      t.binary :minutes_content_data

      t.timestamps
    end
  end
end
