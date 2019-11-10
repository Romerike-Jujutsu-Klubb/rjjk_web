# frozen_string_literal: true

class AddCloudinaryIdentifierToImages < ActiveRecord::Migration[5.2]
  def change
    add_column :images, :cloudinary_identifier, :string
  end
end
