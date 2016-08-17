# frozen_string_literal: true
class AddMessageToPractices < ActiveRecord::Migration
  def change
    add_column :practices, :message, :string
    add_column :practices, :message_nagged_at, :datetime
  end
end
