# frozen_string_literal: true

class AddKjonnToNkfMembers < ActiveRecord::Migration[4.2]
  def change
    add_column :nkf_members, :kjonn, :string, limit: 6, null: false, default: 'Mann'
    change_column_default :nkf_members, :kjonn, from: 'Mann', to: nil
  end
end
