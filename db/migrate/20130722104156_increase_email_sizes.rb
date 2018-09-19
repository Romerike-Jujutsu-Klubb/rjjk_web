# frozen_string_literal: true

class IncreaseEmailSizes < ActiveRecord::Migration[4.2]
  def up
    change_column :members, :parent_email, :string, limit: 64
    change_column :users,   :email,        :string, limit: 64, null: false
  end

  def down; end
end
