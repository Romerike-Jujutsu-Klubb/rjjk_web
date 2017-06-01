# frozen_string_literal: true

class MakeEmailRequiredForMembers < ActiveRecord::Migration[5.0]
  def change
    reversible { |dir| dir.up { execute "UPDATE members SET email = '' WHERE email IS NULL" } }
    change_column_null :members, :email, false
  end
end
