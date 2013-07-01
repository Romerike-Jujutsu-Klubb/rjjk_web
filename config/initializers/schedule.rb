# encoding: utf-8

unless Rails.env == 'test'
  scheduler = Rufus::Scheduler.start_new

  scheduler.cron('0 * * * *') { send_news }
  scheduler.cron('5 * * * *') { send_event_messages }
  scheduler.cron('10 7-23 * * *') { import_nkf_changes }
  scheduler.cron('0 0 * * *') { notify_wrong_contracts }
  scheduler.cron('0 3 * * *') { notify_missing_semesters }
  scheduler.cron('0 4 * * *') { create_missing_group_semesters }
  scheduler.cron('0 4 1 * *') { notify_missing_group_semesters }
  scheduler.cron('0 5 1 * *') { InstructionReminder.notify_missing_instructors }
  scheduler.cron('0 6 * * *') { notify_missing_graduations }
  scheduler.cron('0 7 1 * *') { notify_overdue_graduates }
  scheduler.cron('0 8 1 * *') { send_attendance_plan }
end

private

def logger
  ActiveRecord::Base.logger
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
  rescue
    logger.error 'Execption sending NKF import email.'
    logger.error $!.message
    logger.error $!.backtrace.join("\n")
  end

  begin
    c = NkfMemberComparison.new
    if c.any?
      NkfReplication.update_members(c).deliver
      logger.info 'Sent member comparison mail.'
    end
  rescue
    logger.error 'Execption sending update_members email.'
    logger.error $!.message
    logger.error $!.backtrace.join("\n")
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
  end

  EventInviteeMessage.where('ready_at IS NOT NULL AND sent_at IS NULL').all.each do |eim|
    begin
      NewsletterMailer.event_invitee_message(eim).deliver
      eim.update_attributes! :sent_at => now
    rescue
      logger.error "Exception sending event message for #{eim.inspect}\n#{$!}"
      logger.error $!.backtrace.join("\n")
    end
  end
end

def notify_wrong_contracts
  begin
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
  end
end

def notify_missing_semesters
  begin
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
  end
end

def create_missing_group_semesters
  begin
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
  end
end

def notify_missing_group_semesters
  begin
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
  end
end

def notify_missing_graduations
  begin
    today = Date.today
    groups = Group.active(today).all
    #planned_graduations = Graduation.where('held_on >= ?').all.map(&:)
    missing_schedules = group_schedules.select { |gs| gs.group_instructors.select(&:active?).empty? }
    InstructionMailer.missing_instructors(missing_schedules).deliver if missing_schedules.any?
  rescue
    logger.error "Exception sending instruction message: #{$!}"
    logger.error $!.backtrace.join("\n")
  end
end

def notify_overdue_graduates
  begin
    overdue_graduates = Member.active(today).all
    #planned_graduations = Graduation.where('held_on >= ?').all.map(&:)
    missing_schedules = group_schedules.select { |gs| gs.group_instructors.select(&:active?).empty? }
    InstructionMailer.missing_instructors(missing_schedules).deliver if missing_schedules.any?
  rescue
    logger.error "Exception sending instruction message: #{$!}"
    logger.error $!.backtrace.join("\n")
  end
end

def send_attendance_plan
  member = Member.find(81)
  AttendanceMailer.plan(member).deliver
  member = Member.find(279)
  AttendanceMailer.plan(member).deliver
end
