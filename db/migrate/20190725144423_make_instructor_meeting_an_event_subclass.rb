# frozen_string_literal: true

class MakeInstructorMeetingAnEventSubclass < ActiveRecord::Migration[5.2]
  def change
    remove_column :events, :invitees, :string

    InstructorMeeting.all.each do |im|
      Event.create! type: 'InstructorMeeting', name: im.title.presence || 'Instruktørsamling',
          start_at: im.start_at, end_at: im.end_at.on(im.start_at.to_date), description: im.agenda
    end

    drop_table :instructor_meetings do |t|
      t.datetime 'start_at', null: false
      t.time 'end_at', null: false
      t.string 'title', limit: 254
      t.text 'agenda'
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end
  end

  class InstructorMeeting < ApplicationRecord
  end
end
