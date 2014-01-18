class CreateExaminers < ActiveRecord::Migration
  def change
    create_table :examiners do |t|
      t.integer :graduation_id, :null => false
      t.integer :member_id, :null => false
      t.datetime :requested_at
      t.datetime :confirmed_at
      t.datetime :approved_grades_at

      t.timestamps
    end

    add_column :censors, :requested_at, :datetime
    add_column :censors, :confirmed_at, :datetime
    add_column :censors, :approved_grades_at, :datetime

    Censor.includes(:graduation).where("graduations.held_on < '2013-12-01'").each do |c|
      c.update_attributes! :approved_grades_at => c.graduation.held_on
    end
  end

  class Graduation < ActiveRecord::Base ; end
  class Censor < ActiveRecord::Base
    belongs_to :graduation
  end
end
