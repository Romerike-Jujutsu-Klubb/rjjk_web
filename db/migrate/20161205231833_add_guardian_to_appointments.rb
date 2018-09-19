# frozen_string_literal: true

class AddGuardianToAppointments < ActiveRecord::Migration[4.2]
  def change
    add_column :appointments, :guardian_index, :integer
    rename_column :elections, :guardian, :guardian_index
  end
end
