# frozen_string_literal: true

class CreateRawIncomingEmails < ActiveRecord::Migration[4.2]
  def change
    create_table :raw_incoming_emails do |t|
      t.binary :content, null: false
      t.datetime :processed_at

      t.timestamps
    end
  end
end
