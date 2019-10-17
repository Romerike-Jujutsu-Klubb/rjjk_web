# frozen_string_literal: true

class AddDiscountOverrideToMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :discount_override, :integer
  end
end
