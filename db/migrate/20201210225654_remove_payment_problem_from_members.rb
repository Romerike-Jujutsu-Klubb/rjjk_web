# frozen_string_literal: true

class RemovePaymentProblemFromMembers < ActiveRecord::Migration[6.0]
  def change
    remove_column :members, :payment_problem, :boolean
  end
end
