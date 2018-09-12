# frozen_string_literal: true

if defined?(Rails::Console)
  Rails.logger.info('Disable scheduler since Console is defined.')
elsif caller.none? { |l| l =~ /config.ru/ }
  Rails.logger.info('Disable scheduler since we are not running as a rack application')
elsif caller.any? { |l| l =~ %r{/lib/rake/task.rb:\d+:in `execute'} }
  Rails.logger.info('Disable scheduler since we are running Rake')
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
      loop do
        Rails.logger.error "#{e.class}: #{e.message}"
        Rails.logger.error e
        Rails.logger.error e.backtrace.join("\n")
        break unless e.cause

        e = e.cause
      end
      raise e if Rails.env.test?

      ExceptionNotifier.notify_exception(e)
    end

    # email
    scheduler.every('10s') { Rails.application.executor.wrap { IncomingEmailProcessor.forward_emails } }
    scheduler.every('10s') { Rails.application.executor.wrap { UserMessageSender.send } }

    # Users
    scheduler.cron('0 7    * * mon') do
      Rails.application.executor.wrap { AttendanceNagger.send_attendance_plan }
    end
    scheduler.cron('0 8    * * thu') do
      Rails.application.executor.wrap { InformationPageNotifier.send_weekly_info_page }
    end
    scheduler.cron('0 7-23 * * *') { Rails.application.executor.wrap { NewsPublisher.send_news } }
    scheduler.cron('5 7    * * *') do
      Rails.application.executor.wrap { AttendanceNagger.send_attendance_summary }
    end
    scheduler.cron('5 8-23 * * *') do
      Rails.application.executor.wrap { AttendanceNagger.send_attendance_changes }
    end
    scheduler.cron('8/15 * * * *') do
      Rails.application.executor.wrap { AttendanceNagger.send_attendance_review }
    end
    scheduler.cron('9 9-23 * * *') do
      Rails.application.executor.wrap { EventNotifier.send_event_messages }
    end

    # TODO(uwe): Limit messages to once per week: news, survey, info
    # TODO(uwe): Email board meeting minutes
    # TODO(uwe): Register belt sizes for members.
    # TODO(uwe): Register shirt sizes for members.
    # TODO(uwe): Register jacket sizes for members?
    # TODO(uwe): Lage info side om jakkene.

    scheduler.cron('10 10 * * mon') { Rails.application.executor.wrap { SurveySender.send_surveys } }

    # Board weekly
    scheduler.cron('0 11 * * mon') do
      Rails.application.executor.wrap { AnnualMeetingReminder.notify_missing_date }
    end

    # Admin Hourly
    scheduler.cron('15 9-23 * * *') do
      Rails.application.executor.wrap { NkfSynchronizationJob.perform_now }
    end
    scheduler.cron('10 * * * *') do
      Rails.application.executor.wrap { AttendanceNagger.send_message_reminder }
    end

    # Admin Daily

    # TODO(uwe): Change to update the contracts in NKF
    scheduler.cron('0 0 * * *') do
      Rails.application.executor.wrap { NkfReplicationNotifier.notify_wrong_contracts }
    end
    # ODOT

    scheduler.cron('0 3 * * *') do
      Rails.application.executor.wrap { SemesterReminder.create_missing_semesters }
    end

    scheduler.cron('0 4 * * *') do
      Rails.application.executor.wrap { GroupSemester.create_missing_group_semesters }
    end

    scheduler.cron('0 1 * * mon') do
      Rails.application.executor.wrap { GraduationReminder.notify_overdue_graduates }
    end
    scheduler.cron('0 1 * * *') do
      Rails.application.executor.wrap { GraduationReminder.notify_missing_graduations }
    end
    scheduler.cron('*/5 * * * *') do
      Rails.logger.info 'Running hyper-scheduled jobs:'
      Rails.application.executor.wrap do
        GraduationReminder.notify_groups
        GraduationReminder.notify_missing_censors
        GraduationReminder.notify_censors
        GraduationReminder.notify_missing_locks
        GraduationReminder.invite_graduates
        GraduationReminder.send_shopping_list
        GraduationReminder.notify_missing_approvals
        GraduationReminder.congratulate_graduates
      end
    end

    # Admin Weekly
    scheduler.cron('0 2 * * mon') do
      Rails.application.executor.wrap { InformationPageNotifier.notify_outdated_pages }
    end
    scheduler.cron('0 3 * * mon') do
      Rails.application.executor.wrap { InstructionReminder.notify_missing_instructors }
    end
    scheduler.cron('0 4 * * mon') do
      Rails.application.executor.wrap { NkfMemberTrialReminder.notify_overdue_trials }
    end
    scheduler.cron('0 6 * * mon') do
      Rails.application.executor.wrap { SemesterReminder.notify_missing_session_dates }
    end
    scheduler.cron('0 7 * * mon') do
      Rails.application.executor.wrap { PublicRecordImporter.import_public_record }
    end
    scheduler.cron('0 8 * * mon') { Rails.application.executor.wrap { SurveySender.notify_new_ansers } }

    Rails.logger.info('Scheduler started')
  rescue => e
    Rails.logger.info("Scheduler not started: #{e}")
  end
end
