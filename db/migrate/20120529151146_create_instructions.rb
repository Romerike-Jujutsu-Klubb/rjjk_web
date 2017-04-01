# frozen_string_literal: true

class CreateInstructions < ActiveRecord::Migration
  def change
    create_table :instructions do |t|
      t.integer :group_id
      t.integer :member_id
      t.date :from

      t.timestamps
    end
  end

  add_column :groups, :closed_on, :date
end
