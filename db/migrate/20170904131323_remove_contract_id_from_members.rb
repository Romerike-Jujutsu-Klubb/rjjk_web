# frozen_string_literal: true

class RemoveContractIdFromMembers < ActiveRecord::Migration[5.0]
  def change
    remove_column :members, :contract_id, :integer, references: nil
    remove_column :members, :rfid, :integer
  end
end
