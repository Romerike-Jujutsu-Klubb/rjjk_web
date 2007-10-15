class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.column :name, :string, :limit => 64, :null => false
      t.column :content_type, :string, :null => false
      t.column :content_data, :binary, :null => false
    end
  end

  def self.down
    drop_table :images
  end
end
