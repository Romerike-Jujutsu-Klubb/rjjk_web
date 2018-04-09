class AddParent2EmailToMembers < ActiveRecord::Migration[5.1]
  def change
    add_column :members, :parent_2_email, :string, limit: 64
  end
end
