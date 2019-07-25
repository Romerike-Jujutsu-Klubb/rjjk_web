# frozen_string_literal: true

class AddEventTypeToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :type, :string
  end
end
