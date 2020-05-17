# frozen_string_literal: true

class MakeUrlsUniquePerLinkable < ActiveRecord::Migration[6.0]
  def change
    remove_index :technique_links, %w[linkable_id position]
    remove_index :technique_links, %w[linkable_id url]
    remove_index :technique_links, ['linkable_id']
    add_index :technique_links, %w[linkable_type linkable_id position], unique: true,
        name: :idx_technique_links_on_linkable_type_et_linkable_id_et_position
  end
end
