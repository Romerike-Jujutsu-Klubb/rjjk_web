scheduler = Rufus::Scheduler.start_new
scheduler.every('60m', :first_in => '10s') do
  i = NkfMemberImport.new
  NkfReplication.import_changes(i).deliver if i.any?
end
