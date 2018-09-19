# frozen_string_literal: true

class CreateUserMessages < ActiveRecord::Migration[4.2]
  def change
    create_table :user_messages do |t|
      t.integer :user_id, null: false
      t.string :tag, limit: 64
      t.string :key, null: false, limit: 64
      t.string :from, null: false
      t.string :subject, null: false, limit: 160
      t.datetime :message_timestamp
      t.string :email_url, limit: 254
      t.string :user_email, limit: 128
      t.string :title, limit: 64
      t.text :html_body
      t.text :plain_body
      t.datetime :sent_at
      t.datetime :read_at

      t.timestamps null: false
    end
  end
end
