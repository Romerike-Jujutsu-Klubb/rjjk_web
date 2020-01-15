# frozen_string_literal: true

class MoveRankFromGroupToCurriculumGroup < ActiveRecord::Migration[6.0]
  def change
    change_column :martial_arts, :name, :string, limit: 32
    add_reference :groups, :curriculum_group, foreign_key: true
    add_reference :ranks, :curriculum_group, foreign_key: true
    Group.order(:from_age, :to_age).each do |practice_group|
      cg_attrs = practice_group.attributes.slice('martial_art_id', 'name', 'from_age', 'to_age', 'color')
      cg = CurriculumGroup.create!(cg_attrs)
      practice_group.update! curriculum_group_id: cg.id
      Rank.where(group_id: practice_group.id).update_all(curriculum_group_id: cg.id) # rubocop: disable Rails/SkipsModelValidations
    end
    change_column_null :groups, :curriculum_group_id, false
    remove_column :groups, :martial_art_id, :integer
    change_column_null :ranks, :curriculum_group_id, false
    remove_column :ranks, :group_id, :curriculum_group_id
    remove_column :ranks, :martial_art_id, :integer
    remove_index :basic_techniques, [:name]
  end
end
