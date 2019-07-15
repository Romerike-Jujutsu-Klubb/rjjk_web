# frozen_string_literal: true

class RenameKanjiToKana < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :kanji, :kana
  end
end
