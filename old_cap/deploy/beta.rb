set :application, 'rjjk_web_beta'
set :scm, :copy
# set :repository, '.'
set :repo_url, '.'
set :deploy_to, "/u/apps/#{fetch :application}"

# set :copy_via, :sftp
# set :copy_local_tar, '/usr/bin/tar' if `uname` =~ /Darwin/
set :keep_releases, 1
before('deploy') { `rake tmp:clear` ; FileUtils.rm_rf 'coverage'  ; FileUtils.rm_rf Dir['log/*'] }
after 'deploy:update', 'deploy:cleanup'

role :web, 'kubosch.no'
role :app, 'kubosch.no'
role :db,  'kubosch.no', primary: true

set :user, 'capistrano'
set(:rails_env) { fetch(:stage) }

namespace :deploy do
  desc 'The spinner task is used by :cold_deploy to start the application up'
  task :spinner, roles: :app do
    run "#{try_sudo} systemctl start #{application}"
  end
  
  desc 'Restart the service'
  task :restart, roles: :app do
    run "#{try_sudo} systemctl stop #{application}"
    sleep 5
    run "/u/apps/#{application}/current/copy_production_to_beta.sh"
    run "#{try_sudo} systemctl start #{application}"
  end
end
