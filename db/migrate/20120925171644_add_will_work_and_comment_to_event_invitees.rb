# frozen_string_literal: true

class AddWillWorkAndCommentToEventInvitees < ActiveRecord::Migration[4.2]
  def change
    add_column :event_invitees, :will_work, :boolean
    add_column :event_invitees, :comment, :string
  end
end
