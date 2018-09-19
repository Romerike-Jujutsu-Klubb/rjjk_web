# frozen_string_literal: true

class CreateCorrespondences < ActiveRecord::Migration[4.2]
  def change
    create_table :correspondences do |t|
      t.datetime :sent_at
      t.integer :member_id
      t.integer :related_model_id, references: nil

      t.timestamps
    end
  end
end
