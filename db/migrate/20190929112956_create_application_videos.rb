# frozen_string_literal: true

class CreateApplicationVideos < ActiveRecord::Migration[5.2]
  def change
    create_table :application_videos do |t|
      t.references :technique_application, foreign_key: true
      t.references :image, foreign_key: true

      t.timestamps
    end
  end
end
