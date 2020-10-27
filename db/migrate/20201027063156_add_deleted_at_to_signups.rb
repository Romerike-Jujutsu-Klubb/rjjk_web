# frozen_string_literal: true

class AddDeletedAtToSignups < ActiveRecord::Migration[6.0]
  def change
    add_column :signups, :deleted_at, :datetime
    add_index :signups, :deleted_at
  end
end
