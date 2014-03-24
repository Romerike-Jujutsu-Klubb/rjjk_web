class CreateApplicationSteps < ActiveRecord::Migration
  def change
    create_table :application_steps do |t|
      t.integer :technique_application_id, null: false
      t.integer :position, null: false
      t.text :description
      t.string :image_filename
      t.string :image_content_type
      t.binary :image_content_data

      t.timestamps

      t.index [:technique_application_id, :position]
    end
  end
end
