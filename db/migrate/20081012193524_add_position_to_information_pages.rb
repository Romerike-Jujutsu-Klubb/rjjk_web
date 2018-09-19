# frozen_string_literal: true

class AddPositionToInformationPages < ActiveRecord::Migration[4.2]
  def self.up
    add_column :information_pages, :position, :integer
  end

  def self.down; end
end
