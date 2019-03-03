class AddIconClassToInformationPages < ActiveRecord::Migration[5.2]
  def change
    add_column :information_pages, :icon_class, :string
  end
end
