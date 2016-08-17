# frozen_string_literal: true
class CreatePublicRecords < ActiveRecord::Migration
  def change
    create_table :public_records do |t|
      t.string :contact, null: false
      t.string :chairman, null: false
      t.string :board_members, null: false
      t.string :deputies, null: false

      t.timestamps
    end
  end
end
