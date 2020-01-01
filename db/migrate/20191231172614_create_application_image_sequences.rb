# frozen_string_literal: true

class CreateApplicationImageSequences < ActiveRecord::Migration[5.2]
  def change
    create_table :application_image_sequences do |t|
      t.references :technique_application, foreign_key: true, null: false
      t.integer :position, null: false
      t.string :title

      t.index %i[technique_application_id position], unique: true,
          name: 'idx_app_image_seqs_on_technique_application_id_and_position'
      t.timestamps
    end
  end
end
