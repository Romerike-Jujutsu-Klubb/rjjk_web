# frozen_string_literal: true

class CreateGroupMemberships < ActiveRecord::Migration
  def change
    rename_table :groups_members, :group_memberships
    add_column :group_memberships, :id, :primary_key
  end
end
