class CreateMemberImages < ActiveRecord::Migration
  def change
    create_table :member_images do |t|
      t.integer :member_id,                 :null => false
      t.string :filename,     :limit => 64, :null => false
      t.string :content_type, :limit => 64, :null => false
      t.binary :data,                       :null => false

      t.timestamps
    end

    add_index :member_images, :member_id, :unique => true

    execute "INSERT INTO member_images(member_id, filename, content_type, data, created_at, updated_at)
             SELECT id, image_name, image_content_type, image, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                    FROM members
                    WHERE image_name IS NOT NULL AND image_content_type IS NOT NULL AND image IS NOT NULL"

    remove_column :members, :image_name
    remove_column :members, :image_content_type
    remove_column :members, :image
  end
end
