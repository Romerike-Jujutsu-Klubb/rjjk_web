class AddBillingEmailToMembers < ActiveRecord::Migration
  def change
    add_column :members, :billing_email, :string, :limit => 32
  end
end
