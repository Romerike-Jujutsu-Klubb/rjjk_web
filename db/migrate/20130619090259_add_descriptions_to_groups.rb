class AddDescriptionsToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :summary, :string
    add_column :groups, :description, :text
  end
end
