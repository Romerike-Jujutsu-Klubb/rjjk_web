unless Rails.env == 'test'
  scheduler = Rufus::Scheduler.start_new

  scheduler.every('60m', :first_in => '20s') do
    begin
      i = NkfMemberImport.new
      NkfReplication.import_changes(i).deliver if i.any?
      Rails.logger.info "Sent NKF member import mail."
    rescue
      Rails.logger.error "Execption sending NKF import email."
      Rails.logger.error $!.message
      Rails.logger.error $!.backtrace.join("\n")
    end

    begin
      c = NkfMemberComparison.new
      NkfReplication.update_members(c).deliver if c.any?
      Rails.logger.info "Sent member comparison mail."
    rescue
      Rails.logger.error "Execption sending update_members email."
      Rails.logger.error $!.message
      Rails.logger.error $!.backtrace.join("\n")
    end
  end

  scheduler.every('1m', :first_in => '10s') do
    begin
      now = Time.now

      # FIXME(uwe): Consider using SQL to optimize the selection.
      EventMessage.where('message_type <> ? AND ready_at IS NOT NULL', EventMessage::MessageType::INVITATION).
          order(:ready_at).includes(:event => {:event_invitees => :invitation}).all.each do |em|
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
      Rails.logger.error "Execption sending event messages."
      Rails.logger.error $!.message
      Rails.logger.error $!.backtrace.join("\n")
    end

    EventInviteeMessage.where('ready_at IS NOT NULL AND sent_at IS NULL').all.each do |eim|
      begin
        NewsletterMailer.event_invitee_message(eim).deliver
        eim.update_attributes! :sent_at => now
      rescue
        Rails.logger.error "Exception sending event message: #{$!}"
        Rails.logger.error $!.backtrace.join("\n")
      end
    end

  end

end
