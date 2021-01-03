# frozen_string_literal: true

class AddContractBindingEndOnToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :contract_binding_end_on, :date
  end
end
