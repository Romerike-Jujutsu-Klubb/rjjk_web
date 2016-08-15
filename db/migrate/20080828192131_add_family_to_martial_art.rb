class AddFamilyToMartialArt < ActiveRecord::Migration
  def self.up
    add_column :martial_arts, :family, :string, limit: 16, null: false, default: 'Jujutsu'
    change_column :martial_arts, :family, :string, default: nil
    ma = MartialArt.find_by_name('Aikikai')
    ma.update_attributes! family: 'Aikido' if ma
  end

  def self.down
    remove_column :martial_arts, :family
  end

  class MartialArt < ActiveRecord::Base; end
end
