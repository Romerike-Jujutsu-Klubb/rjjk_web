class CreateMemberImages < ActiveRecord::Migration
  def change
    create_table :member_images do |t|
      t.integer :member_id, :null => false
      t.integer :image_id, :null => false
      t.string :type, :null => false, :limit => 16
      t.timestamps
    end
  end
end
