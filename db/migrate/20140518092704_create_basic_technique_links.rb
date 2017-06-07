# frozen_string_literal: true

class CreateBasicTechniqueLinks < ActiveRecord::Migration
  def change
    create_table :basic_technique_links do |t|
      t.integer :basic_technique_id, null: false
      t.string :title, limit: 64
      t.string :url, null: false, limit: 128
      t.integer :position, null: false

      t.timestamps
      t.index %i[basic_technique_id position], unique: true
      t.index %i[basic_technique_id url], unique: true
    end
  end
end
