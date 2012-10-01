unless Rails.env == 'test'
  scheduler = Rufus::Scheduler.start_new

  scheduler.every('60m', :first_in => '10m') do
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
    now = Time.now
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
