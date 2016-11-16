# frozen_string_literal: true
class SemesterReminder
  def self.notify_missing_semesters
    unless Semester.where('? BETWEEN start_on AND end_on', Date.current).exists?
      recipient = Role[:Leder] || Role[:Nestleder] || Role[:Hovedinstruktør]
      SemesterMailer.missing_current_semester(recipient).store(recipient, tag: :missing_semester)
      return
    end
    unless Semester.where('? BETWEEN start_on AND end_on', Date.current + 4.months).exists?
      recipient = Role[:Leder] || Role[:Nestleder] || Role[:Kasserer]
      SemesterMailer.missing_next_semester(recipient).store(recipient, tag: :missing_next_semester)
    end
  end

  # Ensure first and last sessions are set
  def self.notify_missing_session_dates
    Group.active(Date.current).includes(:current_semester, :next_semester)
        .where('groups.school_breaks = ?', true).all
        .select { |g| g.current_semester.last_session.nil? || g.next_semester.first_session.nil? }
        .each do |g|
      recipient = g.current_semester.chief_instructor || Role[:Hovedinstruktør] || Role[:Leder]
      SemesterMailer.missing_session_dates(recipient, g)
          .store(recipient.user_id, tag: :missing_session_dates)
    end
  end
end
