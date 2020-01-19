# frozen_string_literal: true

class AddRegistrationUrlToExternalEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :registration_url, :string, limit: 128
  end
end
