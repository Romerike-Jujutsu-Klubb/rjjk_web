# frozen_string_literal: true
class AddEventMessageIdToEventInviteeMessages < ActiveRecord::Migration
  def change
    add_column :event_invitee_messages, :event_message_id, :integer
  end
end
