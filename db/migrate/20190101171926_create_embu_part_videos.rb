# frozen_string_literal: true

class CreateEmbuPartVideos < ActiveRecord::Migration[5.2]
  def change
    create_table :embu_part_videos do |t|
      t.references :embu_part, foreign_key: true, null: false
      t.references :image, foreign_key: true, null: false
      t.text :comment

      t.timestamps
    end
  end
end
