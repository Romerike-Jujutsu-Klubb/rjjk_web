class AddGuardianToMember < ActiveRecord::Migration
  def change
    add_column :members, :parent_email, :string, limit: 32
    add_column :members, :parent_2_name, :string, limit: 64
    add_column :members, :parent_2_mobile, :string, limit: 16
  end
end
