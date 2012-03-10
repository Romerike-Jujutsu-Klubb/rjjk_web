class AddLocationToMembers < ActiveRecord::Migration
  def change
    add_column :members, :latitude, :float #you can change the name, see wiki
    add_column :members, :longitude, :float #you can change the name, see wiki
    add_column :members, :gmaps, :boolean #not mandatory, see wiki
  end
end
