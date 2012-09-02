class AddInviteesToEvents < ActiveRecord::Migration
  def change
    add_column :events, :invitees, :text
  end
end
