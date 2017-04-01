# frozen_string_literal: true

class AddMissingTimestamps < ActiveRecord::Migration
  def change
    %i(censors graduates graduations martial_arts members ranks users).each do |table|
      add_timestamps table, null: false, default: '2016-12-01'
      change_column_default table, :created_at, nil
      change_column_default table, :updated_at, nil
    end
  end
end
