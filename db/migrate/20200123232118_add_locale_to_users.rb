# frozen_string_literal: true

class AddLocaleToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :locale, :string, limit: 2, default: 'nb', null: false
    change_column_default :users, :locale, from: 'nb', to: nil
  end
end
