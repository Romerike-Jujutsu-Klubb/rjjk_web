class AddBillingEmailToMembers < ActiveRecord::Migration
  def change
    add_column :members, :billing_email, :string, :limit => 64
  end
end
