# frozen_string_literal: true

class AddColorToGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :color, :string, limit: 16
  end
end
