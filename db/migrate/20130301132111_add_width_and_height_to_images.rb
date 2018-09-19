# frozen_string_literal: true

class AddWidthAndHeightToImages < ActiveRecord::Migration[4.2]
  def change
    add_column :images, :width, :integer
    add_column :images, :height, :integer
  end
end
