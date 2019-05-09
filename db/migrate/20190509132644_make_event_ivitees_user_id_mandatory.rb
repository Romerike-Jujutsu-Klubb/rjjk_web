# frozen_string_literal: true

class MakeEventIviteesUserIdMandatory < ActiveRecord::Migration[5.2]
  def change
    change_column_null :event_invitees, :event_id, false
    change_column_null :event_invitees, :user_id, false
  end
end
