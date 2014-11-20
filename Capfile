load 'deploy'
load 'deploy/assets'

set :stages, %w(beta production)
set :default_stage, 'beta'
set :default_environment, {'JRUBY_OPTS' => '--2.0 --server'}
# set :migrate_env, 'JRUBY_OPTS="--2.0 --server -J-Xmx3G"'

require 'rubygems'
require 'bundler/capistrano'
require 'capistrano/ext/multistage'
require "rvm/capistrano"

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
  run "#{try_sudo} cd #{current_path}/public ; cp 503_down.html 503.html"
end

before 'deploy:create_symlink', :announce_maintenance
after 'deploy:create_symlink', :announce_maintenance
after 'deploy', :end_maintenance

set :rvm_ruby_string, :jruby        # use the same ruby as used locally for deployment
set :rvm_autolibs_flag, 'read-only' # more info: rvm help autolibs

before 'deploy:setup', 'rvm:install_rvm'  # install/update RVM
before 'deploy:setup', 'rvm:install_ruby' # install Ruby and create gemset, OR:

# before 'deploy', 'rvm:install_rvm'  # install/update RVM
# before 'deploy', 'rvm:install_ruby' # install Ruby and create gemset (both if missing)
