# frozen_string_literal: true

class AllowEventWithoutStopDate < ActiveRecord::Migration[4.2]
  def self.up
    change_column_null :events, :end_at, true
  end

  def self.down
    change_column_null :events, :end_at, false
  end
end
