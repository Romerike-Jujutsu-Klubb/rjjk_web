# frozen_string_literal: true

class CreateEmbuParts < ActiveRecord::Migration[5.2]
  def change
    create_table :embu_parts do |t|
      t.references :embu, foreign_key: true, null: false
      t.integer :position, null: false
      t.text :description

      t.timestamps
    end
  end
end
