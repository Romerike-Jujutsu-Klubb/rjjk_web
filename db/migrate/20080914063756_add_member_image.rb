# frozen_string_literal: true

class AddMemberImage < ActiveRecord::Migration
  def self.up
    add_column :members, :image, :binary
    add_column :members, :image_name, :string, limit: 64
    add_column :members, :image_content_type, :string, limit: 32
  end

  def self.down
    remove_column :members, :image_content_type
    remove_column :members, :image_name
    remove_column :members, :image
  end
end
