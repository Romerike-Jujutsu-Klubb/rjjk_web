# frozen_string_literal: true
class MakePageAliasesOldPathUnique < ActiveRecord::Migration
  def change
    add_index :page_aliases, :old_path, unique: true
  end
end
