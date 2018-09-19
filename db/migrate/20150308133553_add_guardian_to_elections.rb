# frozen_string_literal: true

class AddGuardianToElections < ActiveRecord::Migration[4.2]
  def change
    add_column :elections, :guardian, :integer
  end
end
