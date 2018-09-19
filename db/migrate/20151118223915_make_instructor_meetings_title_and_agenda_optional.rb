# frozen_string_literal: true

class MakeInstructorMeetingsTitleAndAgendaOptional < ActiveRecord::Migration[4.2]
  def change
    change_column_null :instructor_meetings, :title, true
    change_column_null :instructor_meetings, :agenda, true
  end
end
