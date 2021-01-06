# frozen_string_literal: true

class AddWelcomePackageToSignups < ActiveRecord::Migration[6.0]
  def change
    add_column :signups, :welcome_package, :boolean
  end
end
