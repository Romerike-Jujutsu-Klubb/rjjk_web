# frozen_string_literal: true

class CreateFrontPageSections < ActiveRecord::Migration[5.2]
  def change
    create_table :front_page_sections do |t|
      t.integer :position, null: false
      t.string :title
      t.string :subtitle
      t.references :image, foreign_key: true
      t.string :button_text
      t.references :information_page, foreign_key: true

      t.timestamps
    end
  end
end
