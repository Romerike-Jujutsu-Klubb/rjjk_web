# frozen_string_literal: true

class ChangeDeletedToDeletedAtForUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :deleted_at, :datetime
    reversible { |dir| dir.up { execute "UPDATE users SET deleted_at = '2018-09-04' WHERE deleted" } }
    remove_column :users, :deleted, :boolean
  end
end
