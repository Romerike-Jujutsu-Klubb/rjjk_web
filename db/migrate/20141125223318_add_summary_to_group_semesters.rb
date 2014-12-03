class AddSummaryToGroupSemesters < ActiveRecord::Migration
  def change
    add_column :group_semesters, :summary, :text
  end
end
