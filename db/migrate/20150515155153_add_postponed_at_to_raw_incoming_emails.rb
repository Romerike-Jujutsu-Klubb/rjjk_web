class AddPostponedAtToRawIncomingEmails < ActiveRecord::Migration
  def change
    add_column :raw_incoming_emails, :postponed_at, :datetime
  end
end
