# frozen_string_literal: true

class AddInviteesToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :invitees, :text
  end
end
