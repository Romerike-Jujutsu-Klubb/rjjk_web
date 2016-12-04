# frozen_string_literal: true
class IncreaseEmailSizes < ActiveRecord::Migration
  def up
    change_column :members, :parent_email, :string, limit: 64
    change_column :users,   :email,        :string, limit: 64, null: false
  end

  def down; end
end
