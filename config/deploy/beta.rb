set :application, 'rjjk_web_beta'
set :scm, :none
set :repository, '.'
set :deploy_via, :copy
set :copy_via, :sftp
set :copy_local_tar, '/usr/bin/tar' if `uname` =~ /Darwin/
set :keep_releases, 1
before('deploy') { `rake tmp:clear` ; FileUtils.rm_rf 'coverage'  ; FileUtils.rm_rf Dir['log/*'] }
after 'deploy:update', 'deploy:cleanup'

role :web, 'kubosch.no'
role :app, 'kubosch.no'
role :db,  'kubosch.no', :primary => true

set :user, 'capistrano'
set :use_sudo, false
set(:rails_env) { fetch(:stage) }

namespace :deploy do
  desc 'The spinner task is used by :cold_deploy to start the application up'
  task :spinner, :roles => :app do
    send(run_method, "/sbin/service #{application} start")
  end
  
  desc 'Restart the service'
  task :restart, :roles => :app do
    send(run_method, "/sbin/service #{application} stop")
    sleep 5
    send(run_method, "/u/apps/#{application}/current/copy_production_to_beta.sh")
    send(run_method, "/sbin/service #{application} start")
  end
end
