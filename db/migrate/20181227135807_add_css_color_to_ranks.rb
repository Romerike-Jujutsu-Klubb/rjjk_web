# frozen_string_literal: true

class AddCssColorToRanks < ActiveRecord::Migration[5.2]
  def change
    add_column :ranks, :css_color, :string, limit: 24
  end
end
