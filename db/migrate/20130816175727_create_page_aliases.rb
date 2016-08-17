# frozen_string_literal: true
class CreatePageAliases < ActiveRecord::Migration
  def change
    create_table :page_aliases do |t|
      t.string :old_path
      t.string :new_path

      t.timestamps
    end
  end
end
