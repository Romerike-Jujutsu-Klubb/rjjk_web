# frozen_string_literal: true

class AddKanjiToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :kanji, :string
  end
end
