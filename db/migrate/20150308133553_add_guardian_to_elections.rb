# frozen_string_literal: true

class AddGuardianToElections < ActiveRecord::Migration
  def change
    add_column :elections, :guardian, :integer
  end
end
