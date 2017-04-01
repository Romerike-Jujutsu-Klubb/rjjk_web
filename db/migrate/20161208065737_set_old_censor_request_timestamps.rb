# frozen_string_literal: true

class SetOldCensorRequestTimestamps < ActiveRecord::Migration
  def change
    execute <<~SQL
      UPDATE censors SET requested_at = created_at WHERE requested_at IS NULL AND examiner = true
    SQL
  end
end
