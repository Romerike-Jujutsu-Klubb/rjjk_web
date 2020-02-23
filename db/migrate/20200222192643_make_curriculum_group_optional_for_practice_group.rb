# frozen_string_literal: true

class MakeCurriculumGroupOptionalForPracticeGroup < ActiveRecord::Migration[6.0]
  def change
    change_column_null :groups, :curriculum_group_id, true
  end
end
