# config valid only for current version of Capistrano
lock '~>3.4'

set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp')

set :default_env, { JRUBY_OPTS: '"--dev -J-Xmx2G"' }
set :rvm_ruby_version, 'jruby-head'

# before 'deploy:spinner', 'deploy:reload_daemons'
before 'deploy:restart', 'deploy:reload_daemons'
after 'deploy:publishing', 'deploy:restart'

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

desc 'Announce maintenance'
task :announce_maintenance do
  on roles :all do
    within "#{current_path}/public" do
      with rails_env: fetch(:rails_env) do
        execute :cp, '503_update.html 503.html'
      end
    end
  end
end

desc 'End maintenance'
task :end_maintenance do
  on roles :all do
    within "#{current_path}/public" do
      with rails_env: fetch(:rails_env) do
        execute :cp, '503_down.html 503.html'
      end
    end
  end
end

after 'deploy:started', :announce_maintenance
after 'deploy:updated', :announce_maintenance
after 'deploy:published', :announce_maintenance
after 'deploy:finished', :end_maintenance

namespace :deploy do
  task :symlinks do
    on roles :all do
      execute :sudo, "rm -f /usr/lib/systemd/system/#{fetch :application}.service ; sudo ln -s #{current_path}/usr/lib/systemd/system/#{fetch :application}.service /usr/lib/systemd/system/#{fetch :application}.service"
    end
  end

  task :reload_daemons do
    on roles :all do
      execute :sudo, 'systemctl daemon-reload'
    end
  end
end
