# frozen_string_literal: true

class RemoveSecurityTokenFromEventInvitees < ActiveRecord::Migration[6.0]
  def change
    remove_column :event_invitees, :security_token, :string
    remove_column :event_invitees, :security_token_generated_at, :datetime
  end
end
