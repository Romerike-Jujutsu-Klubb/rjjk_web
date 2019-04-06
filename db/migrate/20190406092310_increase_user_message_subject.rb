# frozen_string_literal: true

class IncreaseUserMessageSubject < ActiveRecord::Migration[5.2]
  def change
    change_column :user_messages, :subject, :string, limit: 255
    change_column :user_messages, :title, :string, limit: 255
  end
end
