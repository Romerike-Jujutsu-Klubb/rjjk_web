# frozen_string_literal: true

class CreateUserEmails < ActiveRecord::Migration[5.1]
  def change
    create_table :user_emails do |t|
      t.references :user, foreign_key: true, null: false
      t.string :email, limit: 64, null: false

      t.timestamps
    end
  end
end
