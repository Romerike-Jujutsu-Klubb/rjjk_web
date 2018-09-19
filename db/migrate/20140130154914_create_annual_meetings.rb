# frozen_string_literal: true

class CreateAnnualMeetings < ActiveRecord::Migration[4.2]
  def change
    create_table :annual_meetings do |t|
      t.datetime :start_at
      t.text :invitation
      t.datetime :invitation_sent_at
      t.datetime :public_record_updated_at

      t.timestamps
    end
  end
end
