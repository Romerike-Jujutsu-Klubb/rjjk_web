# frozen_string_literal: true

class AddMessageToPractices < ActiveRecord::Migration[4.2]
  def change
    add_column :practices, :message, :string
    add_column :practices, :message_nagged_at, :datetime
  end
end
