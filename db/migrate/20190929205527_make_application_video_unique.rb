# frozen_string_literal: true

class MakeApplicationVideoUnique < ActiveRecord::Migration[5.2]
  def change
    add_index :application_videos, %i[technique_application_id image_id], unique: true,
        name: 'idx_application_videos_on_technique_application_id_and_image_id'
  end
end
