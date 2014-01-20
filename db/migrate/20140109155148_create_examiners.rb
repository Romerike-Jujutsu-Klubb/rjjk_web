class CreateExaminers < ActiveRecord::Migration
  def change
    add_column :censors, :examiner, :boolean
    add_column :censors, :requested_at, :datetime
    add_column :censors, :confirmed_at, :datetime
    add_column :censors, :approved_grades_at, :datetime

    Censor.select('*').includes(:graduation).
        where("graduations.held_on < '2013-12-01'").each do |c|
      c.update_attributes! :requested_at => c.graduation.held_on,
          :confirmed_at => c.graduation.held_on,
          :approved_grades_at => c.graduation.held_on
    end
  end

  class Graduation < ActiveRecord::Base;end
  class Censor < ActiveRecord::Base
    belongs_to :graduation
  end
end
