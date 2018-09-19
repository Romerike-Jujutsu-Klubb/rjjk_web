# frozen_string_literal: true

class CreateExaminers < ActiveRecord::Migration[4.2]
  def change
    add_column :censors, :examiner, :boolean
    add_column :censors, :requested_at, :datetime
    add_column :censors, :confirmed_at, :datetime
    add_column :censors, :approved_grades_at, :datetime

    reversible do |dir|
      dir.up do
        execute "UPDATE censors AS c
          SET requested_at = g.held_on, confirmed_at = g.held_on, approved_grades_at = g.held_on
          FROM graduations AS g
          WHERE c.graduation_id = g.id AND g.held_on < '2013-12-01'"
      end
    end
  end
end
