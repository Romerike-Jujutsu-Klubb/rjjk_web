class CreateCorrespondences < ActiveRecord::Migration
  def change
    create_table :correspondences do |t|
      t.datetime :sent_at
      t.integer :member_id
      t.integer :related_model_id

      t.timestamps
    end
  end
end
