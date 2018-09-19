# frozen_string_literal: true

class MakeGraduationIdAndMemberIdUniqueForCensors < ActiveRecord::Migration[4.2]
  def up
    add_index :censors, %i[graduation_id member_id], unique: true
  end

  def down
    remove_index :censors, %i[graduation_id member_id]
  end
end
