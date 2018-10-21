# frozen_string_literal: true

class CreateAttendanceWebpushes < ActiveRecord::Migration[5.2]
  def change
    create_table :attendance_webpushes do |t|
      t.references :member, null: false
      t.string :endpoint, null: false
      t.string :p256dh, null: false
      t.string :auth, null: false

      t.timestamps
    end
  end
end
