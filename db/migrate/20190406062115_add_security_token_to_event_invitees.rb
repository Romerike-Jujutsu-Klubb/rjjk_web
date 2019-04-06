# frozen_string_literal: true

class AddSecurityTokenToEventInvitees < ActiveRecord::Migration[5.2]
  def change
    add_column :event_invitees, :security_token, :string
    add_column :event_invitees, :security_token_generated_at, :datetime
  end
end
