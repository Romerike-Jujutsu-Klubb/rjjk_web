# frozen_string_literal: true

class MoveApplicationStepImagesToImages < ActiveRecord::Migration[5.2]
  def change
    add_column :application_steps, :image_id, :integer
    ApplicationStep.where.not(image_content_data: nil).each do |as|
      image = Image.create!(user_id: 1, name: as.image_filename, content_type: as.image_content_type,
          content_data: as.image_content_data)
      as.update! image_id: image.id
    end
    remove_column :application_steps, :image_filename, :string
    remove_column :application_steps, :image_content_type, :string
    remove_column :application_steps, :image_content_data, :binary
  end
  class ApplicationStep < ApplicationRecord
  end
  class Image < ApplicationRecord
  end
end
