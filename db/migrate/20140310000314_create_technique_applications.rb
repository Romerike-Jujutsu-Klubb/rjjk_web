class CreateTechniqueApplications < ActiveRecord::Migration
  def change
    create_table :technique_applications do |t|
      t.string :name, null: false
      t.boolean :kata, null: false, default: false
      t.integer :rank_id

      t.timestamps
      t.index [:rank_id, :name], unique: true
    end
  end
end
