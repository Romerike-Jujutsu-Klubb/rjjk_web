# frozen_string_literal: true

class AddPhoneToEventInvitee < ActiveRecord::Migration[4.2]
  def change
    add_column :event_invitees, :phone, :string
  end
end
