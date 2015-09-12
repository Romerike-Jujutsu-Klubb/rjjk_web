set :application, 'rjjk_web_beta'
set :scm, :copy
set :repo_url, '.'
set :deploy_to, -> { "/u/apps/#{fetch :application}" }
set :keep_releases, 1
set :exclude_dir, %w(coverage doc log test tmp)
set :include_dir, '{.ruby-version,*}'

role :app, %w{capistrano@kubosch.no}
role :web, %w{capistrano@kubosch.no}
role :db, %w{capistrano@kubosch.no}

server 'kubosch.no', user: 'capistrano', roles: %w{web app}, my_property: :my_value

namespace :deploy do
  desc 'The spinner task is used by :cold_deploy to start the application up'
  task :spinner do
    on roles :all do
      execute :sudo, "systemctl start #{fetch :application}"
    end
  end

  desc 'Restart the service'
  task :restart do
    on roles :all do
      execute :sudo, "systemctl stop #{fetch :application}"
      execute "#{fetch :rvm_path}/bin/rvm #{fetch :rvm_ruby_version} do #{current_path}/copy_production_to_beta.sh"
      execute :sudo, "systemctl start #{fetch :application}"
    end
  end
end
