class AddFamilyToMartialArt < ActiveRecord::Migration
  def self.up
    add_column :martial_arts, :family, :string, :limit => 16, :null => false, :default => 'Jujutsu'
    change_column_default :martial_arts, :family, nil
    MartialArt.find_by_name('Aikikai').update_attributes! :family => 'Aikido'
  end

  def self.down
    remove_column :martial_arts, :family
  end
end
