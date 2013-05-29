# encoding: utf-8

unless Rails.env == 'test'
  scheduler = Rufus::Scheduler.start_new

  scheduler.every('1h', :first_in => '10s') { send_news }
  scheduler.every('1h', :first_in => '30s') { send_event_messages }
  scheduler.cron('0 7-23 * * *') { import_nkf_changes }
  scheduler.cron('0 0 * * *') { notify_wrong_contracts }
  scheduler.cron('0 8 1 * *') { notify_missing_instructors }
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
    logger.error $!.backtrace
  end
end

def notify_missing_instructors
  begin
    groups = Group.active(Date.today).all
    group_schedules = groups.map(&:group_schedules).flatten
    missing_schedules = group_schedules.select{|gs| gs.group_instructors.select(&:active?).empty?}
    InstructionMailer.missing_instructors(missing_schedules).deliver if missing_schedules.any?
  rescue
    logger.error "Exception sending instruction message: #{$!}"
    logger.error $!.backtrace
  end
end
