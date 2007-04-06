set :application, "rjjk"
set :repository, "svn+ssh://donv@source.kubosch.no/var/svn/trunk/rjjk_web"

role :app, "www.kubosch.no"

set :user, "donv"

ssh_options[:keys] = %w(/home/uwe/.ssh/id_rsa)

desc "The spinner task is used by :cold_deploy to start the application up"
task :spinner, :roles => :app do
  send(run_method, "/sbin/service rjjk start")
end

desc "Restart the mongrel server"
task :restart, :roles => :app do
  send(run_method, "/sbin/service rjjk restart")
end

