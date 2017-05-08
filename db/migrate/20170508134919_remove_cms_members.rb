# frozen_string_literal: true

class RemoveCmsMembers < ActiveRecord::Migration[5.0]
  def up
    remove_column :members, :cms_contract_id
    drop_table :cms_members
  end
end
