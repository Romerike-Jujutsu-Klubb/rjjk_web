class CreateRawIncomingEmails < ActiveRecord::Migration
  def change
    create_table :raw_incoming_emails do |t|
      t.binary :content

      t.timestamps
    end
  end
end
