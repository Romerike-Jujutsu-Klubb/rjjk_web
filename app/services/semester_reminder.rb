# frozen_string_literal: true

class SemesterReminder
  def self.create_missing_semesters
    return if Semester.exists?(['? BETWEEN start_on AND end_on', Date.current + 3.months])

    logger.warn 'The next semester is missing.  Creating it.'
    last_end_date = Semester.order(:end_on).last&.end_on || Date.current.beginning_of_year - 1.day
    start_date = last_end_date + 1.day
    end_date = last_end_date + 6.months
    Semester.create! start_on: start_date, end_on: end_date
  end

  # Ensure first and last sessions are set
  def self.notify_missing_session_dates
    active_groups = Group.active(Date.current).includes(:current_semester, :next_semester)
        .where('groups.school_breaks = ?', true).to_a
    groups_with_missing_dates = active_groups.select do |g|
      g.current_semester&.last_session.nil? || (g.next_semester && !g.next_semester.first_session)
    end
    groups_with_missing_dates.each do |g|
      recipient = g.current_semester.chief_instructor || Role[:'Hovedinstruktør'] || Role[:Leder]
      SemesterMailer.missing_session_dates(recipient, g)
          .store(recipient.user_id, tag: :missing_session_dates)
    end
  end
end
