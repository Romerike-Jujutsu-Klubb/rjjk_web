class CreateTechniqueApplications < ActiveRecord::Migration
  def change
    create_table :technique_applications do |t|
      t.string :name, null: false
      # t.integer :attack_id, null: false
      t.integer :rank_id

      t.timestamps
      # t.index [:attack_id, :rank_id], unique: true
      t.index [:rank_id, :name], unique: true
    end
  end
end
