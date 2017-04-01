# frozen_string_literal: true

class CreateTechniqueApplications < ActiveRecord::Migration
  def change
    create_table :technique_applications do |t|
      t.string :name, null: false
      t.string :system, null: false
      t.integer :rank_id

      t.timestamps
      t.index %i(rank_id name), unique: true
    end
  end
end
