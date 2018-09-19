# frozen_string_literal: true

class AddBillingEmailToMembers < ActiveRecord::Migration[4.2]
  def change
    add_column :members, :billing_email, :string, limit: 64
  end
end
