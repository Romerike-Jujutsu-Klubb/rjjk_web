# frozen_string_literal: true

class CreateMemberUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :member_users do |t|
      t.references :member, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.string :relationship, limit: 16, null: false

      t.timestamps
    end
  end
end
