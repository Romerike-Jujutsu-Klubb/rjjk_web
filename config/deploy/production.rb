set :application, 'rjjk_web'
set :repository, "svn+ssh://capistrano@source.kubosch.no/var/svn/trunk/#{application}"

role :app, 'kubosch.no'
role :db,  'kubosch.no', :primary => true

set :user, 'capistrano'
set :use_sudo, false

namespace :deploy do
  desc 'The spinner task is used by :cold_deploy to start the application up'
  task :spinner, :roles => :app do
    send(run_method, "/sbin/service #{application} start")
  end
  
  desc 'Restart the service'
  task :restart, :roles => :app do
    send(run_method, "/sbin/service #{application} restart")
  end
end
