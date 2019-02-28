# frozen_string_literal: true

class AddPublicToInformationPages < ActiveRecord::Migration[5.2]
  def change
    add_column :information_pages, :public, :boolean, null: false, default: true
    change_column_default :information_pages, :public, from: true, to: nil
  end
end
