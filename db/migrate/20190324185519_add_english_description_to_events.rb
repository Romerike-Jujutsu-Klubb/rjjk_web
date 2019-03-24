# frozen_string_literal: true

class AddEnglishDescriptionToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :name_en, :string, limit: 80
    add_column :events, :description_en, :text
  end
end
