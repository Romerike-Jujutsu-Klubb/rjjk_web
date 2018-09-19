# frozen_string_literal: true

class MakeGraduatePassedOptional < ActiveRecord::Migration[4.2]
  def up
    change_column_null :graduates, :passed, true
  end

  def down
    change_column_null :graduates, :passed, false
  end
end
