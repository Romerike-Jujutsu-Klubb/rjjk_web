# frozen_string_literal: true
class CreateEventInvitees < ActiveRecord::Migration
  def change
    create_table :event_invitees do |t|
      t.integer :event_id
      t.string :email
      t.string :name
      t.string :address
      t.string :organization
      t.boolean :will_attend
      t.integer :payed

      t.timestamps
    end
  end
end
