# frozen_string_literal: true

class AddForeignKeyFromEventInviteeToUser < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :event_invitees, :users
  end
end
