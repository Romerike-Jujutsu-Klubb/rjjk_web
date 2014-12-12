# encoding: utf-8

# http://www.gotealeaf.com/blog/handling-emails-in-rails?utm_source=rubyweekly&utm_medium=email

unless Rails.env == 'test'
  scheduler = Rufus::Scheduler.new max_work_threads: 1

  # Users
  scheduler.cron('0 7    * * mon') { AttendanceNagger.send_attendance_plan }
  scheduler.cron('0 8    * * thu') { InformationPageNotifier.send_weekly_info_page }
  scheduler.cron('0 8-23 * * *') { NewsPublisher.send_news }
  scheduler.cron('5 7    * * *') { AttendanceNagger.send_attendance_summary }
  scheduler.cron('5 8-23 * * *') { AttendanceNagger.send_attendance_changes }
  scheduler.cron('8/15 * * * *') { AttendanceNagger.send_attendance_review }
  scheduler.cron('9 9-23 * * *') { EventNotifier.send_event_messages }
  scheduler.cron('10 10 * * *') { StartSurvey.send_survey }

  # Admin Hourly
  scheduler.cron('15 9-23 * * *') { NkfMemberImport.import_nkf_changes }
  scheduler.cron('10 * * * *') { AttendanceNagger.send_message_reminder }

  # Admin Daily
  scheduler.cron('0 0 * * *') { notify_wrong_contracts }
  scheduler.cron('0 3 * * *') { notify_missing_semesters }
  scheduler.cron('0 4 * * *') { create_missing_group_semesters }
  scheduler.cron('0 6 * * *') { GraduationReminder.notify_missing_graduations }
  scheduler.cron('0 10 * * *') { GraduationReminder.notify_missing_aprovals }
  scheduler.cron('0 11 * * *') { AnnualMeetingReminder.notify_missing_date }

  # Admin Weekly
  scheduler.cron('0 1 * * mon') { GraduationReminder.notify_overdue_graduates }
  scheduler.cron('0 2 * * mon') { InformationPageNotifier.notify_outdated_pages }
  scheduler.cron('0 3 * * mon') { InstructionReminder.notify_missing_instructors }
  scheduler.cron('0 4 * * mon') { NkfMemberTrialReminder.notify_overdue_trials }
  scheduler.cron('0 5 * * mon') { NkfMemberTrialReminder.send_waiting_lists }
  scheduler.cron('0 6 * * mon') { notify_missing_group_semesters }
  scheduler.cron('0 7 * * mon') { PublicRecordImporter.import_public_record }
end

private

def notify_wrong_contracts
  members = NkfMember.where(:medlemsstatus => 'A').all
  wrong_contracts = members.select { |m|
    m.member &&
        (m.member.age < 10 && m.kont_sats !~ /^Barn/) ||
        (m.member.age >= 10 && m.member.age < 15 && m.kont_sats !~ /^Ungdom|Trenere/) ||
        (m.member.age >= 15 && m.kont_sats !~ /^(Voksne|Styre|Trenere|Æresmedlem)/)
  }
  NkfReplication.wrong_contracts(wrong_contracts).deliver if wrong_contracts.any?
rescue
  logger.error "Exception sending contract message: #{$!}"
  logger.error $!.backtrace.join("\n")
  ExceptionNotifier.notify_exception($!)
end

def notify_missing_semesters
  unless Semester.where('CURRENT_DATE BETWEEN start_on AND end_on').exists?
    SemesterMailer.missing_current_semester.deliver
    return
  end
  unless Semester.where('? BETWEEN start_on AND end_on', Date.today + 6.months).exists?
    SemesterMailer.missing_next_semester.deliver
  end
rescue
  logger.error "Exception sending semester message: #{$!}"
  logger.error $!.backtrace.join("\n")
  ExceptionNotifier.notify_exception($!)
end

def create_missing_group_semesters
  groups = Group.active.all
  Semester.all.each do |s|
    groups.each do |g|
      cond = {:group_id => g.id, :semester_id => s.id}
      GroupSemester.create! cond unless GroupSemester.exists? cond
    end
  end
rescue
  logger.error "Exception sending semester message: #{$!}"
  logger.error $!.backtrace.join("\n")
  ExceptionNotifier.notify_exception($!)
end

def notify_missing_group_semesters
  # Ensure first and last sessions are set
  Group.active(Date.today).includes(:current_semester, :next_semester).
      where('groups.school_breaks = ?', true).all.
      select { |g| g.current_semester.last_session.nil? }.
      select { |g| g.next_semester.first_session.nil? }.
      each do |g|
    SemesterMailer.missing_session_dates(g).deliver
  end
rescue
  logger.error "Exception sending session dates message: #{$!}"
  logger.error $!.backtrace.join("\n")
  ExceptionNotifier.notify_exception($!)
end
