# frozen_string_literal: true

class MakePageAliasesOldPathUnique < ActiveRecord::Migration[4.2]
  def change
    add_index :page_aliases, :old_path, unique: true
  end
end
