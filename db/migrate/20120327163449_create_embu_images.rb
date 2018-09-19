# frozen_string_literal: true

class CreateEmbuImages < ActiveRecord::Migration[4.2]
  def change
    create_table :embu_images do |t|
      t.integer :embu_id, null: false
      t.integer :image_id, null: false

      t.timestamps
    end
  end
end
