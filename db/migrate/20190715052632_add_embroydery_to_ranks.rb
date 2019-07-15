# frozen_string_literal: true

class AddEmbroyderyToRanks < ActiveRecord::Migration[5.2]
  def change
    add_column :ranks, :embroydery, :boolean
  end
end
