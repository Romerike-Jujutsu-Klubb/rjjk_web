# frozen_string_literal: true

class AddEventMessageIdToEventInviteeMessages < ActiveRecord::Migration[4.2]
  def change
    add_column :event_invitee_messages, :event_message_id, :integer
  end
end
