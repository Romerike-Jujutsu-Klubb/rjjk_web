# frozen_string_literal: true

class AddWillWorkAndCommentToEventInvitees < ActiveRecord::Migration
  def change
    add_column :event_invitees, :will_work, :boolean
    add_column :event_invitees, :comment, :string
  end
end
