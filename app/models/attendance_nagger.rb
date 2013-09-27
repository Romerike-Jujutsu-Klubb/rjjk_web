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
    group_schedules = GroupSchedule.includes(:group).
        where('weekday = ? AND end_at >= ? AND groups.closed_on IS NULL AND (groups.school_breaks IS NULL OR groups.school_breaks = ?)',
              now.to_date.cwday, now.time_of_day, false).all
    group_schedules.each do |gs|
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
        end
        AttendanceMailer.changes(gs, recipient, new_attendees, displayed_absentees, attendees).deliver
      end
    end
  rescue Exception
    logger.error $!
    ExceptionNotifier.notify_exception($!)
  end

end
