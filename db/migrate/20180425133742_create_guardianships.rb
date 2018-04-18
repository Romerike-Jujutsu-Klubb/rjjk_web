# frozen_string_literal: true

class CreateGuardianships < ActiveRecord::Migration[5.1]
  def change
    create_table :guardianships do |t|
      t.references :ward_user, foreign_key: { to_table: :users }, null: false
      t.references :guardian_user, foreign_key: { to_table: :users }, null: false
      t.integer :index, null: false

      t.timestamps

      t.index %w[ward_user_id index], unique: true
    end
  end
end
