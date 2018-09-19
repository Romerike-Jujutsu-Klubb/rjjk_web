# frozen_string_literal: true

class AddPostponedAtToRawIncomingEmails < ActiveRecord::Migration[4.2]
  def change
    add_column :raw_incoming_emails, :postponed_at, :datetime
  end
end
