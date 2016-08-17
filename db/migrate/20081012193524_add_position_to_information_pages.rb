# frozen_string_literal: true
class AddPositionToInformationPages < ActiveRecord::Migration
  def self.up
    add_column :information_pages, :position, :integer
  end

  def self.down
  end
end
