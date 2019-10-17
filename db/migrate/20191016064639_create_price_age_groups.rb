# frozen_string_literal: true

class CreatePriceAgeGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :price_age_groups do |t|
      t.string :name, null: false, index: { unique: true }
      t.integer :from_age, null: false, index: { unique: true }
      t.integer :to_age, null: false, index: { unique: true }
      t.integer :yearly_fee, null: false
      t.integer :monthly_fee, null: false

      t.timestamps
    end
    rename_column :groups, :monthly_price, :monthly_fee
    rename_column :groups, :yearly_price, :yearly_fee
  end
end
