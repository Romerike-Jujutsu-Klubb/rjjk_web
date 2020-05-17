# frozen_string_literal: true

class MakeTechniqueLinksPolymorphic < ActiveRecord::Migration[6.0]
  def change
    rename_table :basic_technique_links, :technique_links
    add_column :technique_links, :linkable_type, :string, null: false, default: :BasicTechnique
    change_column_default :technique_links, :linkable_type, from: :BasicTechnique, to: nil
    rename_column :technique_links, :basic_technique_id, :linkable_id
    add_index :technique_links, %i[linkable_type linkable_id]
    add_index :technique_links, %i[linkable_type linkable_id url], unique: true
  end
end
