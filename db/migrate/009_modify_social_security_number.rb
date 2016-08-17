# frozen_string_literal: true
class ModifySocialSecurityNumber < ActiveRecord::Migration
  def self.up
    change_column :members, :social_sec_no, :string, limit: 11
  end

  def self.down
    change_column :members, :social_sec_no, :string, limit: 6
  end
end
