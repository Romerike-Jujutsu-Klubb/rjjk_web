# frozen_string_literal: true

class ModifySocialSecurityNumber < ActiveRecord::Migration[4.2]
  def self.up
    change_column :members, :social_sec_no, :string, limit: 11
  end

  def self.down
    change_column :members, :social_sec_no, :string, limit: 6
  end
end
