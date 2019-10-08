# frozen_string_literal: true

class ChangeNkfFieldKontraktsbelopToString < ActiveRecord::Migration[5.2]
  def up
    change_column :nkf_members, :kontraktsbelop, :string, limit: 255
  end

  def down
    change_column :nkf_members, :kontraktsbelop, 'integer USING CAST(kontraktsbelop AS integer)'
  end
end
