# frozen_string_literal: true

class AddLocationToMembers < ActiveRecord::Migration[4.2]
  def change
    add_column :members, :latitude, :float # you can change the name, see wiki
    add_column :members, :longitude, :float # you can change the name, see wiki
    add_column :members, :gmaps, :boolean # not mandatory, see wiki
  end
end
