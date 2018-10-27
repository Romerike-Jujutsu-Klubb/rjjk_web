# frozen_string_literal: true

class DropRawIncomingEmails < ActiveRecord::Migration[5.2]
  def change
    drop_table :raw_incoming_emails do
      create_table 'raw_incoming_emails' do |t|
        t.binary 'content', null: false
        t.datetime 'created_at'
        t.datetime 'updated_at'
        t.datetime 'processed_at'
        t.datetime 'postponed_at'
      end
    end
  end
end
