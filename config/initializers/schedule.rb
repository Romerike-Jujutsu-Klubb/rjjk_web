# frozen_string_literal: true

if defined?(Rails::Console)
  Rails.logger.info("Disable scheduler since Console is defined.")
elsif !%w[development beta production].include?(Rails.env)
  Rails.logger.info("Disable scheduler since env == #{Rails.env}")
elsif ENV['DISABLE_SCHEDULER'].present?
  Rails.logger.info("Disable scheduler since ENV['DISABLE_SCHEDULER'] is set")
else
  begin
    scheduler =
        Rufus::Scheduler.new lockfile: "#{Rails.root}/tmp/rufus-scheduler.lock", max_work_threads: 1
    if scheduler.down?
      Rails.logger.info 'Scheduler is down.  Stopping.'
      return
    end
    Rails.logger.info('Starting scheduler')

    def scheduler.on_error(job, e)
      Rails.logger.error "Exception during scheduled job(#{job.tags}): #{e}"
      Rails.logger.error e.backtrace.join("\n")
      if e.is_a?(ActiveRecord::StatementInvalid)
        ActiveRecord::Base.verify!
        begin
          job.call
          return
        rescue => e2
          Rails.logger.error "Exception re-running scheduled job(#{job.tags}): #{e2}"
        end
      end
      raise e if Rails.env.test?
      ExceptionNotifier.notify_exception(e)
    end

    # email
    scheduler.every('10s') { IncomingEmailProcessor.forward_emails }
    scheduler.every('10s') { UserMessageSender.send }

    # Users
    scheduler.cron('0 7    * * mon') { AttendanceNagger.send_attendance_plan }
    scheduler.cron('0 8    * * thu') { InformationPageNotifier.send_weekly_info_page }
    scheduler.cron('0 7-23 * * *') { NewsPublisher.send_news }
    scheduler.cron('5 7    * * *') { AttendanceNagger.send_attendance_summary }
    scheduler.cron('5 8-23 * * *') { AttendanceNagger.send_attendance_changes }
    scheduler.cron('8/15 * * * *') { AttendanceNagger.send_attendance_review }
    scheduler.cron('9 9-23 * * *') { EventNotifier.send_event_messages }

    # TODO(uwe): Limit messages to once per week: news, survey, info
    # TODO(uwe): Email board meeting minutes
    # TODO(uwe): Register belt sizes for members.
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

    scheduler.cron('0 3 * * *') { SemesterReminder.create_missing_semesters }

    scheduler.cron('0 4 * * *') { GroupSemester.create_missing_group_semesters }

    scheduler.cron('0 1 * * mon') { GraduationReminder.notify_overdue_graduates }
    scheduler.cron('0 1 * * *') { GraduationReminder.notify_missing_graduations }
    scheduler.cron('*/5 * * * *') do
      Rails.logger.info 'Running hyper-scheduled jobs:'
      GraduationReminder.notify_groups
      GraduationReminder.notify_censors
      GraduationReminder.notify_missing_locks
      GraduationReminder.notify_graduates
      GraduationReminder.send_shopping_list
      GraduationReminder.notify_missing_approvals
      GraduationReminder.congratulate_graduates
    end

    # Admin Weekly
    scheduler.cron('0 2 * * mon') { InformationPageNotifier.notify_outdated_pages }
    scheduler.cron('0 3 * * mon') { InstructionReminder.notify_missing_instructors }
    scheduler.cron('0 4 * * mon') { NkfMemberTrialReminder.notify_overdue_trials }
    scheduler.cron('0 6 * * mon') { SemesterReminder.notify_missing_session_dates }
    scheduler.cron('0 7 * * mon') { PublicRecordImporter.import_public_record }

    Rails.logger.info('Scheduler started')
  rescue => e
    Rails.logger.info("Scheduler not started: #{e}")
  end
end
