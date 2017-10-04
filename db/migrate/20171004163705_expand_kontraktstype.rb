# frozen_string_literal: true

class ExpandKontraktstype < ActiveRecord::Migration[5.0]
  def change
    change_column :groups, :contract, :string, limit: 32
  end
end
