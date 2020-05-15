# frozen_string_literal: true

class AddOriginalMartialArtToMartialArts < ActiveRecord::Migration[6.0]
  def change
    add_reference :martial_arts, :original_martial_art, foreign_key: { to_table: :martial_arts }
    add_index :martial_arts, :name, unique: true
  end
end
