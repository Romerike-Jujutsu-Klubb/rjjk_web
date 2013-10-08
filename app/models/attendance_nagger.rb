class AttendanceNagger
  def self.send_attendance_plan
    today = Date.today
    Member.active(today).where('NOT EXISTS (SELECT id FROM attendances WHERE member_id = members.id AND year = ? AND week = ?)',
                               today.cwyear, today.cweek).
        select { |m| m.age >= 14 }.
        select { |m| m.groups.any? { |g| g.name == 'Voksne' } }.
        select { |m| !m.passive? }.
        each do |member|
      if member.user.nil?
        msg = "USER IS MISSING!  #{member.inspect}"
        logger.error msg
        ExceptionNotifier.notify_exception(ActiveRecord::RecordNotFound.new(msg))
        next
      end
      AttendanceMailer.plan(member).deliver
    end
  rescue Exception
    logger.error $!
    ExceptionNotifier.notify_exception($!)
  end

  def self.send_attendance_summary
    now = Time.now
    group_schedules = GroupSchedule.includes(:group).
        where('weekday = ? AND start_at >= ? AND (groups.school_breaks IS NULL OR groups.school_breaks = ?)',
              now.to_date.cwday, now.time_of_day, false)
    group_schedules.each do |gs|
      attendances = Attendance.includes(:group_schedule, :member).
          where(:group_schedule_id => gs.id, :year => now.year, :week => now.to_date.cweek).all
      next if attendances.empty?
      non_attendees = attendances.select { |a| Attendance::ABSENT_STATES.include? a.status }.map(&:member)
      attendees = attendances.map(&:member) - non_attendees
      recipients = gs.group.members.select { |m| !m.passive? } - non_attendees
      recipients.each do |recipient|
        AttendanceMailer.summary(gs, recipient, attendees, non_attendees).deliver
      end
    end
  rescue Exception
    logger.error $!
    ExceptionNotifier.notify_exception($!)
  end

  def self.send_attendance_changes
    now = Time.now
    upcoming_group_schedules = GroupSchedule.includes(:group).
        where('weekday = ? AND end_at >= ? AND groups.closed_on IS NULL AND (groups.school_breaks IS NULL OR groups.school_breaks = ?)',
              now.to_date.cwday, now.time_of_day, false).all
    upcoming_group_schedules.each do |gs|
      attendances = Attendance.includes(:group_schedule, :member).
          where('group_schedule_id = ? AND year = ? AND week = ?',
                gs.id, now.year, now.to_date.cweek).all
      new_attendances = attendances.select { |a| a.updated_at >= 1.hour.ago }.map(&:member)
      next if new_attendances.empty?
      absentees = attendances.select { |a| Attendance::ABSENT_STATES.include? a.status }.map(&:member)
      attendees = attendances.map(&:member) - absentees
      new_attendees = new_attendances & attendees
      new_absentees = new_attendances & absentees
      uwe = Member.find_by_first_name_and_last_name('Uwe', 'Kubosch')
      recipients = gs.group.members.select { |m| !m.passive? } - absentees
      recipients.each do |recipient|
        if recipient != uwe
          next if new_attendances.empty?
          if new_absentees.size > new_attendances.size
            displayed_absentees = []
          else
            displayed_absentees = new_absentees
          end
        else
          displayed_absentees = new_absentees
        end
        AttendanceMailer.changes(gs, recipient, new_attendees, displayed_absentees, attendees).deliver
      end
    end
  rescue Exception
    logger.error $!
    ExceptionNotifier.notify_exception($!)
  end

  def self.send_attendance_review
    now = Time.now
    completed_group_schedules = GroupSchedule.includes(:group).
        where('weekday = ? AND end_at BETWEEN ? AND ? AND groups.closed_on IS NULL AND (groups.school_breaks IS NULL OR groups.school_breaks = ?)',
              now.to_date.cwday, (now - 1.hour).time_of_day, now.time_of_day, false).all
    planned_attendances = Attendance.includes(:group_schedule, :member).
        where('group_schedule_id IN (?) AND year = ? AND week = ? AND status = ? AND sent_review_email_at IS NULL',
              completed_group_schedules.map(&:id), now.year, now.to_date.cweek, Attendance::Status::WILL_ATTEND).all
    planned_attendances.group_by(&:member).each do |member, completed_attendances|
      older_attendances =
          Attendance.where('member_id = ? AND attendances.id NOT IN (?) AND status = ?',
                           member.id, completed_attendances.map(&:id), Attendance::Status::WILL_ATTEND).
              includes(:group_schedule).
              order(:year, :week, 'group_schedules.weekday').all.
              select { |a| a.date <= Date.today }.reverse
      AttendanceMailer.review(member, completed_attendances, older_attendances).deliver
      completed_attendances.each { |a| a.update_attributes :sent_review_email_at => now }
    end
  rescue Exception
    logger.error $!
    ExceptionNotifier.notify_exception($!)
  end

end
