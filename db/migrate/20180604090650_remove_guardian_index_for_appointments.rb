# frozen_string_literal: true

class RemoveGuardianIndexForAppointments < ActiveRecord::Migration[5.1]
  def change
    remove_column :appointments, :guardian_index, :integer
    remove_column :elections, :guardian_index, :integer
  end
end
