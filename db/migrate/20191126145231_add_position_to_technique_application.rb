# frozen_string_literal: true

class AddPositionToTechniqueApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :technique_applications, :position, :integer
    TechniqueApplication.all.group_by(&:rank_id).each do |_rank_id, tas|
      tas.each.with_index do |ta, i|
        ta.update! position: i + 1
      end
    end
    change_column_null :technique_applications, :position, false
  end
end
