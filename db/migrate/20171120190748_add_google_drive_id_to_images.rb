# frozen_string_literal: true

class AddGoogleDriveIdToImages < ActiveRecord::Migration[5.1]
  def change
    add_column :images, :google_drive_reference, :string, limit: 33
  end
end
