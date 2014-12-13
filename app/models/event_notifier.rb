class EventNotifier
  def self.send_event_messages
    begin
      now = Time.now

      # FIXME(uwe): Consider using SQL to optimize the selection.
      EventMessage.where('message_type <> ? AND ready_at IS NOT NULL', EventMessage::MessageType::INVITATION).
          order(:ready_at).includes(:event => {:event_invitees => :invitation},
                                    :event_invitee_messages => :event_invitee).to_a.each do |em|
        recipients = em.event.event_invitees
        recipients = recipients.select { |r| r.will_attend || r.invitation.try(:sent_at) }
        already_received = em.event_invitee_messages.map(&:event_invitee)
        recipients -= already_received
        recipients.each do |ei|
          EventInviteeMessage.create! event_message_id: em.id,
              event_invitee_id: ei.id, message_type: em.message_type,
              subject: em.subject, body: em.body, ready_at: now
        end
      end
    rescue
      logger.error 'Execption sending event messages.'
      logger.error $!.message
      logger.error $!.backtrace.join("\n")
      ExceptionNotifier.notify_exception($!)
    end

    EventInviteeMessage.where('ready_at IS NOT NULL AND sent_at IS NULL').to_a.each do |eim|
      begin
        NewsletterMailer.event_invitee_message(eim).deliver
        eim.update_attributes! sent_at: now
      rescue
        logger.error "Exception sending event message for #{eim.inspect}\n#{$!}"
        logger.error $!.backtrace.join("\n")
        ExceptionNotifier.notify_exception($!)
      end
    end
  end
end
