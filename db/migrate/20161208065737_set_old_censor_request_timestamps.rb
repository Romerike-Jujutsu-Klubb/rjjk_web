# frozen_string_literal: true

class SetOldCensorRequestTimestamps < ActiveRecord::Migration[4.2]
  def up
    execute <<~SQL
      UPDATE censors SET requested_at = created_at WHERE requested_at IS NULL AND examiner = true
    SQL
  end
end
