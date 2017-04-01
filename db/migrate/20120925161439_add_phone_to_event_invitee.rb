# frozen_string_literal: true

class AddPhoneToEventInvitee < ActiveRecord::Migration
  def change
    add_column :event_invitees, :phone, :string
  end
end
