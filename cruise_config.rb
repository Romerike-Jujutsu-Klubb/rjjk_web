Project.configure do |project|
  project.email_notifier.emails = ['lars@bratens.net', 'stck_ondemannen@hotmail.com', 'uwe@kubosch.no']
  project.email_notifier.from = 'cruisecontrol@bracon.net'
end
