# frozen_string_literal: true
class CreateBasicTechniques < ActiveRecord::Migration
  def change
    create_table :basic_techniques do |t|
      t.string :name, null: false, index: :unique
      t.string :translation
      t.integer :waza_id, null: false
      t.text :description
      t.integer :rank_id

      t.timestamps
    end
  end
end
