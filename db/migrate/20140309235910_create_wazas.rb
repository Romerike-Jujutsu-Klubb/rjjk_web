# frozen_string_literal: true

class CreateWazas < ActiveRecord::Migration[4.2]
  def change
    create_table :wazas do |t|
      t.string :name, null: false, index: :unique
      t.string :translation
      t.text :description

      t.timestamps
    end
  end
end
