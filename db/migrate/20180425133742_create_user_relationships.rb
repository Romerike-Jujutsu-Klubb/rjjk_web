# frozen_string_literal: true

class CreateUserRelationships < ActiveRecord::Migration[5.1]
  def change
    create_table :user_relationships do |t|
      t.references :downstream_user, foreign_key: { to_table: :users }, null: false
      t.references :upstream_user, foreign_key: { to_table: :users }, null: false
      t.string :kind, null: false

      t.timestamps

      t.index %w[downstream_user_id kind], unique: true
    end
  end
end
