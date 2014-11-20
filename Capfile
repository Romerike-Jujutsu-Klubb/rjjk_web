load 'deploy'
load 'deploy/assets'

set :stages, %w(beta production)
set :default_stage, 'beta'
set :default_environment, {'JRUBY_OPTS' => '--2.0 --server'}
# set :migrate_env, 'JRUBY_OPTS="--2.0 --server -J-Xmx3G"'

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

  echo -n Waiting for server to start
  for j in {1..60} ; do
    if (exec >/dev/null 2>&1 6<>/dev/tcp/127.0.0.1/3000) ; then
      break
    fi
    echo -n .
    sleep 1
  done
  echo -n "$j "
  if (exec >/dev/null 2>&1 6<>/dev/tcp/127.0.0.1/3000) ; then
    echo OK
    sleep 5
    echo "$APP with pid=$PID restarted."
  else
    echo FAILED
    echo "$APP with pid=$PID failed to restart."
  fi

  run "#{try_sudo} cd #{current_path}/public ; cp 503_down.html 503.html"
end

before 'deploy:create_symlink', :announce_maintenance
after 'deploy:create_symlink', :announce_maintenance
after 'deploy', :end_maintenance
