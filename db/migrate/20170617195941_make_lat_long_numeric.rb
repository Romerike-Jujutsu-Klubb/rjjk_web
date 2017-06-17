# frozen_string_literal: true

class MakeLatLongNumeric < ActiveRecord::Migration[5.0]
  def change
    change_column :members, :latitude, :decimal, scale: 6, precision: 8
    change_column :members, :longitude, :decimal, scale: 6, precision: 9
  end
end
