# frozen_string_literal: true

class CreateImages < ActiveRecord::Migration[4.2]
  def self.up
    create_table :images do |t|
      t.column :name, :string, limit: 64, null: false
      t.column :content_type, :string, null: false
      t.column :content_data, :binary, null: false
      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
