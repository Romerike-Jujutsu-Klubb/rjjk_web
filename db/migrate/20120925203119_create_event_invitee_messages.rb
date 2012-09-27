class CreateEventInviteeMessages < ActiveRecord::Migration
  def change
    create_table :event_invitee_messages do |t|
      t.integer :event_invitee_id
      t.string :message_type
      t.string :subject
      t.text :body
      t.datetime :ready_at
      t.datetime :sent_at

      t.timestamps
    end
  end
end
