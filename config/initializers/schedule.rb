scheduler = Rufus::Scheduler.start_new
scheduler.every('60m', :first_in => '1m'){NkfMemberImport.new}
