# frozen_string_literal: true

class AttendanceNagger
  AGE_LIMIT = 13

  def self.send_attendance_plan
    today = Date.current
    Member.active(today)
        .where('NOT EXISTS (
SELECT a.id FROM attendances a INNER JOIN practices p ON a.practice_id = p.id
WHERE member_id = members.id AND year = ? AND week = ?)',
            today.cwyear, today.cweek)
        .order(:joined_on)
        .select { |m| m.groups.any?(&:planning) }
        .select(&:active?)
        .each do |member|
      if member.user.nil?
        msg = "USER IS MISSING!  #{member.inspect}"
        logger.error msg
        ExceptionNotifier.notify_exception(ActiveRecord::RecordNotFound.new(msg))
        next
      end
      AttendanceMailer.plan(member).store(member, tag: :attendance_plan)
    end
  end

  def self.send_attendance_summary
    now = Time.current
    group_schedules = GroupSchedule.includes(:group).references(:groups)
        .merge(Group.active(now))
        .where('weekday = ? AND start_at >= ?', now.to_date.cwday, now.time_of_day)
        .where('groups.planning = ?', true)
        .order('groups.from_age', 'groups.to_age')
        .to_a
    group_schedules.each do |gs|
      attendances = Attendance.includes(:member, practice: :group_schedule)
          .where(practices: { group_schedule_id: gs.id, year: now.year, week: now.to_date.cweek })
          .to_a
      next if attendances.empty?
      practice = attendances[0].practice
      non_attendees = attendances.select { |a| Attendance::ABSENT_STATES.include? a.status }.map(&:member)
      attendees = attendances.map(&:member) - non_attendees
      recipients = gs.group.members.order(:joined_on, :id).reject(&:passive?) - non_attendees
      recipients.each do |recipient|
        AttendanceMailer.summary(practice, gs, recipient, attendees, non_attendees)
            .store(recipient, tag: :attendance_summary)
      end
    end
  end

  def self.send_message_reminder
    tomorrow = Date.tomorrow
    practices = Practice.includes(group_schedule: :group).references(:group_schedules)
        .where('message IS NULL AND message_nagged_at IS NULL')
        .where('year = ? AND week = ? AND group_schedules.weekday = ?',
            tomorrow.year, tomorrow.cweek, tomorrow.cwday)
        .where('(group_schedules.start_at <= ? OR group_schedules.start_at <= ?)',
            Time.current.time_of_day, Time.current.time_of_day + 3600)
        .where('groups.planning = ?', true) # TODO(uwe): Make a scope :with_planning
        .to_a
    practices.each do |pr|
      pr.group_schedule.group_instructors.active.each do |gi|
        AttendanceMailer.message_reminder(pr, gi.member)
            .store(gi.member, tag: :instructor_message_reminder)
      end
      pr.update_attributes message_nagged_at: Time.current
    end
  end

  def self.send_attendance_changes
    now = Time.current
    upcoming_group_schedules = GroupSchedule.includes(:group).references(:groups)
        .where('weekday = ? AND end_at >= ? AND groups.closed_on IS NULL',
            now.to_date.cwday, now.time_of_day)
        .where('groups.planning = ?', true)
        .to_a
    upcoming_group_schedules.each do |gs|
      attendances = Attendance.includes(:member, practice: :group_schedule)
          .references(:practices)
          .where('practices.group_schedule_id = ? AND year = ? AND week = ?',
              gs.id, now.year, now.to_date.cweek).to_a
      new_attendances = attendances.select { |a| a.updated_at >= 1.hour.ago }.map(&:member)
      next if new_attendances.empty?
      practice = attendances[0].practice
      absentees = attendances.select { |a| Attendance::ABSENT_STATES.include? a.status }
          .map(&:member)
      attendees = attendances.map(&:member) - absentees
      new_attendees = new_attendances & attendees
      new_absentees = new_attendances & absentees
      uwe = User.find_by(first_name: 'Uwe', last_name: 'Kubosch').member
      recipients = gs.group.members.order(:joined_on).reject(&:passive?) - absentees
      recipients.each do |recipient|
        if recipient != uwe
          next if new_attendances.empty?
          displayed_absentees = if new_absentees.size > new_attendances.size
                                  []
                                else
                                  new_absentees
                                end
        else
          displayed_absentees = new_absentees
        end
        AttendanceMailer
            .changes(practice, gs, recipient, new_attendees, displayed_absentees, attendees)
            .store(recipient, tag: :attendance_change)
      end
    end
  end

  def self.send_attendance_review
    now = Time.current
    completed_group_schedules = GroupSchedule.includes(:group).references(:groups)
        .where('weekday = ? AND end_at BETWEEN ? AND ?',
            now.to_date.cwday, (now - 1.hour).time_of_day, now.time_of_day)
        .where('groups.closed_on IS NULL')
        .where('groups.planning = ?', true)
        .to_a
    planned_attendances = Attendance
        .includes(:member, practice: :group_schedule).references(:groups)
        .where('practices.group_schedule_id IN (?)', completed_group_schedules.map(&:id))
        .where('practices.year = ? AND practices.week = ?', now.year, now.to_date.cweek)
        .where('attendances.status = ? AND sent_review_email_at IS NULL',
            Attendance::Status::WILL_ATTEND).to_a
    planned_attendances.group_by(&:member).each do |member, completed_attendances|
      older_attendances =
          Attendance.where('member_id = ? AND attendances.id NOT IN (?) AND attendances.status = ?',
              member.id, completed_attendances.map(&:id), Attendance::Status::WILL_ATTEND)
              .includes(practice: :group_schedule).references(:practices)
              .order('practices.year, practices.week, group_schedules.weekday').to_a
              .select { |a| a.date <= Date.current && a.date >= 1.year.ago }.reverse
      AttendanceMailer.review(member, completed_attendances, older_attendances)
          .store(member, tag: :attendance_review)
      completed_attendances.each { |a| a.update_attributes sent_review_email_at: now }
    end
  end
end
