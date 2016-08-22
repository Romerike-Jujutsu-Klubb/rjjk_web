# frozen_string_literal: true
# http://www.gotealeaf.com/blog/handling-emails-in-rails?utm_source=rubyweekly&utm_medium=email

if %w(development beta production).include?(Rails.env) && !ENV['DISABLE_SCHEDULER']
  scheduler = Rufus::Scheduler.new max_work_threads: 1

  def scheduler.handle_exception(job, e)
    raise e if Rails.env.test?
    logger.error "Exception during scheduled job(#{job.tags}): #{e}"
    logger.error e.backtrace.join("\n")
    ExceptionNotifier.notify_exception(e)
  end

  # email
  scheduler.every(10.seconds) { IncomingEmailProcessor.forward_emails }

  # Users
  scheduler.cron('0 7    * * mon') { AttendanceNagger.send_attendance_plan }
  scheduler.cron('0 8    * * thu') { InformationPageNotifier.send_weekly_info_page }
  scheduler.cron('0 8-23 * * *') { NewsPublisher.send_news }
  scheduler.cron('5 7    * * *') { AttendanceNagger.send_attendance_summary }
  scheduler.cron('5 8-23 * * *') { AttendanceNagger.send_attendance_changes }
  scheduler.cron('8/15 * * * *') { AttendanceNagger.send_attendance_review }
  scheduler.cron('9 9-23 * * *') { EventNotifier.send_event_messages }
  scheduler.every(10.seconds) { UserMessageSender.send }

  # TODO(uwe): Limit messages to once per week: news, survey, info
  # TODO(uwe): Email board meeting minutes
  # TODO(uwe): Register shirt sizes for members.
  # TODO(uwe): Register jacket sizes for members?
  # TODO(uwe): Lage info side om jakkene.

  scheduler.cron('10 10 * * mon') { SurveySender.send_surveys }

  # Board weekly
  scheduler.cron('0 11 * * mon') { AnnualMeetingReminder.notify_missing_date }

  # Admin Hourly
  scheduler.cron('15 9-23 * * *') { NkfMemberImport.import_nkf_changes }
  scheduler.cron('10 * * * *') { AttendanceNagger.send_message_reminder }

  # Admin Daily
  scheduler.cron('0 0 * * *') { NkfReplicationNotifier.notify_wrong_contracts }
  scheduler.cron('0 3 * * *') { SemesterReminder.notify_missing_semesters }
  scheduler.cron('0 4 * * *') { GroupSemester.create_missing_group_semesters }
  scheduler.cron('0 5 * * *') { GraduationReminder.notify_missing_graduations }
  scheduler.cron('0 6 * * *') { GraduationReminder.notify_censors }
  # scheduler.cron('0 * * * *') { GraduationReminder.notify_missing_locks }
  # scheduler.cron('0 * * * *') { GraduationReminder.notify_graduates }
  # scheduler.cron('0 * * * *') { GraduationReminder.send_shopping_list }
  scheduler.cron('0 10 * * *') { GraduationReminder.notify_missing_aprovals }
  # scheduler.cron('0 10 * * *') { GraduationReminder.notify_graduate_result }

  # Admin Weekly
  scheduler.cron('0 1 * * mon') { GraduationReminder.notify_overdue_graduates }
  scheduler.cron('0 2 * * mon') { InformationPageNotifier.notify_outdated_pages }
  scheduler.cron('0 3 * * mon') { InstructionReminder.notify_missing_instructors }
  scheduler.cron('0 4 * * mon') { NkfMemberTrialReminder.notify_overdue_trials }
  scheduler.cron('0 6 * * mon') { SemesterReminder.notify_missing_session_dates }
  scheduler.cron('0 7 * * mon') { PublicRecordImporter.import_public_record }
end
