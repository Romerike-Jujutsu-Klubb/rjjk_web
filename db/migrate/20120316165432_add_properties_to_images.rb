# frozen_string_literal: true
class AddPropertiesToImages < ActiveRecord::Migration
  def change
    create_table :user_images do |t|
      t.integer :user_id, null: false
      t.integer :image_id, null: false
      t.string :rel_type, null: false, limit: 16
      t.timestamps
    end
    add_index :user_images, [:user_id, :image_id, :rel_type], unique: true

    add_column :images, :user_id, :integer
    add_column :images, :description, :string, limit: 16
    add_column :images, :story, :text
    add_column :images, :public, :boolean
    add_column :images, :approved, :boolean

    add_column :users, :member_id, :integer
  end
end
