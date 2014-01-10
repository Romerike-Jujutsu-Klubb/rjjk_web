class CreateExaminers < ActiveRecord::Migration
  def change
    create_table :examiners do |t|
      t.integer :graduation_id
      t.integer :member_id
      t.datetime :requested_at
      t.datetime :confirmed_at
      t.datetime :approved_grades_at

      t.timestamps
    end

    add_column :censors, :requested_at, :datetime
    add_column :censors, :confirmed_at, :datetime
    add_column :censors, :approved_grades_at, :datetime
  end
end
