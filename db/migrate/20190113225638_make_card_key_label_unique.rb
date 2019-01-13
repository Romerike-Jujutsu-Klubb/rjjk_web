# frozen_string_literal: true

class MakeCardKeyLabelUnique < ActiveRecord::Migration[5.2]
  def change
    add_index :card_keys, :label, unique: true
    change_column_null :card_keys, :label, true
  end
end
