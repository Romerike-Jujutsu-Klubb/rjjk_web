set :application, 'rjjk_web'
set :scm, :svn
set :repo_url, "svn+ssh://capistrano@kubosch.no/var/svn/trunk/#{fetch :application}"
set :deploy_to, -> { "/u/apps/#{fetch :application}" }
set :keep_releases, 30

role :app, %w{capistrano@kubosch.no}
role :web, %w{capistrano@kubosch.no}
role :db,  %w{capistrano@kubosch.no}

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
      execute :sudo, "systemctl restart #{fetch :application}"
    end
  end
end
