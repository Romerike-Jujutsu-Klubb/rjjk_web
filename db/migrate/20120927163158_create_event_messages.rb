# frozen_string_literal: true
class CreateEventMessages < ActiveRecord::Migration
  def change
    create_table :event_messages do |t|
      t.integer :event_id
      t.string :message_type
      t.string :subject
      t.text :body
      t.datetime :ready_at

      t.timestamps
    end
  end
end
