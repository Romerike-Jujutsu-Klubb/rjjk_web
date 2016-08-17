# frozen_string_literal: true
class AllowEventWithoutStopDate < ActiveRecord::Migration
  def self.up
    change_column_null :events, :end_at, true
  end

  def self.down
    change_column_null :events, :end_at, false
  end
end
