# frozen_string_literal: true

class EventNotifier
  def self.send_event_messages
    begin
      now = Time.current

      EventMessage
          .where('message_type <> ? AND ready_at IS NOT NULL',
              EventMessage::MessageType::INVITATION)
          .order(:ready_at).includes(event: { event_invitees: :invitation },
                                     event_invitee_messages: :event_invitee).to_a.each do |em|
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
    rescue => e
      logger.error 'Execption sending event messages.'
      logger.error e.message
      logger.error e.backtrace.join("\n")
      ExceptionNotifier.notify_exception(e)
    end

    EventInviteeMessage.where('ready_at IS NOT NULL AND sent_at IS NULL').to_a.each do |eim|
      event_invitee_message = EventMailer.event_invitee_message(eim)
      if eim.event_invitee.user_id
        event_invitee_message.store(eim.event_invitee.user_id, tag: :event_invitee_message)
      else
        event_invitee_message.deliver_now # FIXME(uwe): Remove when all invitees are users
      end
      eim.update! sent_at: now
    rescue => e
      logger.error "Exception sending event message for #{eim.inspect}\n#{e}"
      logger.error e.backtrace.join("\n")
      ExceptionNotifier.notify_exception(e)
    end
  end
end
