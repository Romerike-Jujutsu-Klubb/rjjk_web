# frozen_string_literal: true

class AddHiddenFieldToInformationPages < ActiveRecord::Migration[4.2]
  def self.up
    add_column :information_pages, :hidden, :boolean
  end

  def self.down
    remove_column :information_pages, :hidden
  end
end
