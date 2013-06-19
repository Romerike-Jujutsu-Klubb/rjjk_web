class AddDescriptionsToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :monthly_price, :integer
    add_column :groups, :yearly_price, :integer
    add_column :groups, :contract, :string, :limit => 16
    add_column :groups, :summary, :string
    add_column :groups, :description, :text
  end
end
