# frozen_string_literal: true

class CreateSignups < ActiveRecord::Migration[6.0]
  def change
    create_table :signups do |t|
      t.references :user, null: false, foreign_key: true
      t.references :nkf_member_trial, null: false, foreign_key: true

      t.timestamps
    end
  end
end
