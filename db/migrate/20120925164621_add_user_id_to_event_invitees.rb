# frozen_string_literal: true

class AddUserIdToEventInvitees < ActiveRecord::Migration[4.2]
  def change
    add_column :event_invitees, :user_id, :integer
  end
end
