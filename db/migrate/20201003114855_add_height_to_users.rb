# frozen_string_literal: true

class AddHeightToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :height, :integer, limit: 1
  end
end
