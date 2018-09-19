# frozen_string_literal: true

class AddSummaryToGroupSemesters < ActiveRecord::Migration[4.2]
  def change
    add_column :group_semesters, :summary, :text
  end
end
