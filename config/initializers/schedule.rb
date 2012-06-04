unless Rails.env == 'test'
  scheduler = Rufus::Scheduler.start_new

  scheduler.every('60m', :first_in => '10s') do
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

  scheduler.every('1d', :first_in => '10s') do

  end

end
