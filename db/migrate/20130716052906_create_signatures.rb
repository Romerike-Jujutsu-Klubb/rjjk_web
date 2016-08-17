# frozen_string_literal: true
class CreateSignatures < ActiveRecord::Migration
  def change
    create_table :signatures do |t|
      t.integer :member_id, null: false
      t.string :name, null: false
      t.string :content_type, null: false
      t.binary :image, null: false

      t.timestamps
    end
  end
end
