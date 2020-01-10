# frozen_string_literal: true

class CreateCurriculumGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :curriculum_groups do |t|
      t.string :name, null: false
      t.references :martial_art, null: false, foreign_key: true
      t.integer :position, null: false
      t.integer :from_age, null: false
      t.integer :to_age, null: false
      t.string :color

      t.timestamps
    end
  end
end
