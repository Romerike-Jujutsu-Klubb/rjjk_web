# encoding: utf-8

unless Rails.env == 'test'
  scheduler = Rufus::Scheduler.start_new

  # Users
  scheduler.cron('0 7    * * mon') { AttendanceNagger.send_attendance_plan }
  scheduler.cron('0 8    * * thu') { send_weekly_info_page }
  scheduler.cron('0 8-23 * * *') { send_news }
  scheduler.cron('5 8    * * *') { AttendanceNagger.send_attendance_summary }
  scheduler.cron('5 9-23 * * *') { AttendanceNagger.send_attendance_changes }
  scheduler.cron('9 9-23 * * *') { send_event_messages }

  # Admin Hourly
  scheduler.cron('15 9-23 * * *') { import_nkf_changes }

  # Admin Daily
  scheduler.cron('0 0 * * *') { notify_wrong_contracts }
  scheduler.cron('0 3 * * *') { notify_missing_semesters }
  scheduler.cron('0 4 * * *') { create_missing_group_semesters }
  scheduler.cron('0 6 * * *') { notify_missing_graduations }

  # Admin Weekly
  scheduler.cron('0 8 * * mon') { notify_outdated_pages }
  scheduler.cron('0 2 * * mon') { notify_overdue_trials }
  scheduler.cron('0 4 * * mon') { notify_missing_group_semesters }
  scheduler.cron('0 5 * * mon') { InstructionReminder.notify_missing_instructors }
  scheduler.cron('0 7 * * mon') { notify_overdue_graduates }
end

private

def logger
  ActiveRecord::Base.logger
end

# Flow:
#   Pages should be reviewed at least every 6 months.
#   Old reviewed pages should be sent to new members
#   New pages should be sent to all active members
#   Newly revised pages should be sent to all members unless they got it within the last 6 months,
#     or the change is significat (or should that be in a news item?)
def notify_outdated_pages
  recipients = Member.active(Date.today).includes(:user).where('users.role = ?', 'ADMIN').all
  pages = InformationPage.where('(hidden IS NULL OR hidden = ?) AND revised_at IS NULL OR revised_at < ?', false, 6.months.ago).
      order(:revised_at).limit(3).all
  recipients.each do |recipient|
    InformationPageMailer.notify_outdated_pages(recipient, pages).deliver
  end
rescue
  logger.error 'Execption sending information page notification'
  logger.error $!.message
  logger.error $!.backtrace.join("\n")
  ExceptionNotifier.notify_exception($!)
end

# Flow:
#   Pages should be reviewed at least every 6 months.
#   Old reviewed pages should be sent to new members
#   New pages should be sent to all active members
#   Newly revised pages should be sent to all members unless they got it within the last 6 months,
#     or the change is significat (or should that be in a news item?)
def send_weekly_info_page
  logger.debug 'Sending weekly info page'
  page = InformationPage.where("
(hidden IS NULL OR hidden = ?) AND
(revised_at > CURRENT_TIMESTAMP - interval '6' month) AND
(mailed_at IS NULL OR mailed_at < CURRENT_TIMESTAMP - interval '6' month)", false).
      order(:mailed_at).first
  if page
    Member.active(Date.today).order(:first_name, :last_name).all.each do |m|
      InformationPageMailer.send_weekly_page(m, page).deliver
    end
    page.update_attributes! :mailed_at => Time.now
  end
  logger.debug 'Sending weekly info page...OK'
rescue
  logger.error 'Execption sending news'
  logger.error $!.message
  logger.error $!.backtrace.join("\n")
  ExceptionNotifier.notify_exception($!)
end

def send_news
  logger.debug 'Sending news'
  news_item = NewsItem.where("
mailed_at IS NULL AND
(publication_state IS NULL OR publication_state = 'PUBLISHED') AND
(publish_at IS NULL OR publish_at < CURRENT_TIMESTAMP) AND
(expire_at IS NULL OR expire_at > CURRENT_TIMESTAMP) AND
(updated_at IS NULL OR updated_at < CURRENT_TIMESTAMP - interval '10' minute)").first
  if news_item
    recipients = Rails.env == 'production' ? Member.active(Date.today) : Member.where(:first_name => 'Uwe').all
    recipients.each do |m|
      NewsletterMailer.newsletter(news_item, m).deliver
    end
    news_item.update_attributes! :mailed_at => Time.now
  end
  logger.debug 'Sending news...OK'
rescue
  logger.error 'Execption sending news'
  logger.error $!.message
  logger.error $!.backtrace.join("\n")
  ExceptionNotifier.notify_exception($!)
end

def import_nkf_changes
  begin
    i = NkfMemberImport.new
    if i.any?
      NkfReplication.import_changes(i).deliver
      logger.info 'Sent NKF member import mail.'
      logger.info 'Oppdaterer kontrakter'
      NkfMember.update_group_prices
    end
  rescue Exception
    logger.error 'Execption sending NKF import email.'
    logger.error $!.message
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end

  begin
    c = NkfMemberComparison.new
    if c.any?
      NkfReplication.update_members(c).deliver
      logger.info 'Sent member comparison mail.'
    end
  rescue Exception
    logger.error 'Execption sending update_members email.'
    logger.error $!.message
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end
end

def send_event_messages
  begin
    now = Time.now

    # FIXME(uwe): Consider using SQL to optimize the selection.
    EventMessage.where('message_type <> ? AND ready_at IS NOT NULL', EventMessage::MessageType::INVITATION).
        order(:ready_at).includes(:event => {:event_invitees => :invitation},
                                  :event_invitee_messages => :event_invitee).all.each do |em|
      recipients = em.event.event_invitees
      recipients = recipients.select { |r| r.will_attend || r.invitation.try(:sent_at) }
      already_received = em.event_invitee_messages.map(&:event_invitee)
      recipients -= already_received
      recipients.each do |ei|
        EventInviteeMessage.create! :event_message_id => em.id, :event_invitee_id => ei.id,
                                    :message_type => em.message_type, :subject => em.subject, :body => em.body,
                                    :ready_at => now
      end
    end
  rescue
    logger.error 'Execption sending event messages.'
    logger.error $!.message
    logger.error $!.backtrace.join("\n")
    ExceptionNotifier.notify_exception($!)
  end

  EventInviteeMessage.where('ready_at IS NOT NULL AND sent_at IS NULL').all.each do |eim|
    begin
      NewsletterMailer.event_invitee_message(eim).deliver
      eim.update_attributes! :sent_at => now
    rescue
      logger.error "Exception sending event message for #{eim.inspect}\n#{$!}"
      logger.error $!.backtrace.join("\n")
      ExceptionNotifier.notify_exception($!)
    end
  end
end

def notify_wrong_contracts
  members = NkfMember.where(:medlemsstatus => 'A').all
  wrong_contracts = members.select { |m|
    (m.member.age < 10 && m.kont_sats !~ /^Barn/) ||
        (m.member.age >= 10 && m.member.age < 15 && m.kont_sats !~ /^Ungdom/) ||
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
  # Create missing GroupSemesters
  groups = Group.where('school_breaks = ?', true).all
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

def notify_missing_graduations
  today = Date.today
  groups = Group.active(today).all
  #planned_graduations = Graduation.where('held_on >= ?').all.map(&:)
  missing_schedules = group_schedules.select { |gs| gs.group_instructors.select(&:active?).empty? }
  InstructionMailer.missing_instructors(missing_schedules).deliver if missing_schedules.any?
rescue
  logger.error "Exception sending instruction message: #{$!}"
  logger.error $!.backtrace.join("\n")
  ExceptionNotifier.notify_exception($!)
end

def notify_overdue_graduates
  overdue_graduates = Member.active(today).all
  #planned_graduations = Graduation.where('held_on >= ?').all.map(&:)
  missing_schedules = group_schedules.select { |gs| gs.group_instructors.select(&:active?).empty? }
  InstructionMailer.missing_instructors(missing_schedules).deliver if missing_schedules.any?
rescue
  logger.error "Exception sending instruction message: #{$!}"
  logger.error $!.backtrace.join("\n")
  ExceptionNotifier.notify_exception($!)
end

def notify_overdue_trials
  trials = NkfMemberTrial.where('reg_dato < ?', 2.months.ago).all
  NkfMemberTrialMailer.notify_overdue_trials(trials).deliver
rescue Exception
  logger.error $!
  ExceptionNotifier.notify_exception($!)
end
