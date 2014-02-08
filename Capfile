load 'deploy'
load 'deploy/assets'

set :stages, %w(beta production)
set :default_stage, 'beta'
set :default_environment, {
    'JRUBY_OPTS' => '--2.0 --server',
}

require 'rubygems'
require 'bundler/capistrano'
require 'capistrano/ext/multistage'

desc 'Fix permission'
task :fix_permissions, :roles => [:app, :db, :web] do
  run "#{try_sudo} chmod +rx #{current_path}"
end

after 'deploy:create_symlink', :fix_permissions


desc 'Announce maintenance'
task :announce_maintenance, :roles => [:app] do
  run "#{try_sudo} cd #{current_path}/public ; cp 503_update.html 503.html"
end

desc 'End maintenance'
task :end_maintenance, :roles => [:app] do
  sleep 120
  run "#{try_sudo} cd #{current_path}/public ; cp 503_down.html 503.html"
end

before 'deploy:create_symlink', :announce_maintenance
after 'deploy:create_symlink', :announce_maintenance
after 'deploy', :end_maintenance
