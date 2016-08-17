# frozen_string_literal: true
class AddKjonnToNkfMembers < ActiveRecord::Migration
  def change
    add_column :nkf_members, :kjonn, :string, limit: 6, null: false, default: 'Mann'
    change_column_default :nkf_members, :kjonn, nil
  end
end
