# frozen_string_literal: true

class CorrectBirthDate < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :cms_members, :birtdate, :birthdate
    rename_column :members, :birtdate, :birthdate
  end

  def self.down
    rename_column :members, :birthdate, :birtdate
    rename_column :cms_members, :birthdate, :birtdate
  end
end
