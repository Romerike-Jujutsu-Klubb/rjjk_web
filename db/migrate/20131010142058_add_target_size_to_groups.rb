# frozen_string_literal: true

class AddTargetSizeToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :target_size, :integer
  end
end
