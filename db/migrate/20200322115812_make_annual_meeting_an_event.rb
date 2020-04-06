# frozen_string_literal: true

class MakeAnnualMeetingAnEvent < ActiveRecord::Migration[6.0]
  def up
    remove_foreign_key 'elections', 'annual_meetings', name: 'fk_elections_annual_meeting_id'
    execute('SELECT * FROM annual_meetings').each do |am|
      event = Event.create! type: AnnualMeeting.name, name: 'Årsmøte', start_at: am['start_at'],
          description: am['invitation'], created_at: am['created_at'], updated_at: am['updated_at']
      Election.where(annual_meeting_id: am['id']).each do |e|
        e.update!(annual_meeting_id: event.id)
      end
    end
    drop_table :annual_meetings
    add_foreign_key 'elections', 'events', column: :annual_meeting_id
  end
end
