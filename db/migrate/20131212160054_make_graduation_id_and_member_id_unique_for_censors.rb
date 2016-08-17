# frozen_string_literal: true
class MakeGraduationIdAndMemberIdUniqueForCensors < ActiveRecord::Migration
  def up
    add_index :censors, [:graduation_id, :member_id], unique: true
  end

  def down
    remove_index :censors, [:graduation_id, :member_id]
  end
end
