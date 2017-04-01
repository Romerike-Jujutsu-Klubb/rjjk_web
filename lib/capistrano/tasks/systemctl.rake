# frozen_string_literal: true

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
      execute :sudo,
          "/u/apps/#{fetch :application}/current/etc/init.d/#{fetch :application} restart"
    end
  end

  task :symlinks do
    on roles :all do
      execute :sudo, <<-SCRIPT
        echo "Updating init script"
        rm -f /usr/lib/systemd/system/#{fetch :application}.service
        sudo cp -a #{current_path}/usr/lib/systemd/system/#{fetch :application}.service /usr/lib/systemd/system/#{fetch :application}.service
        echo "Updating httpd config"
        rm -f /etc/httpd/conf.d/*-#{fetch :application}.conf
        sudo cp -a #{current_path}/etc/httpd/conf.d/*-#{fetch :application}.conf /etc/httpd/conf.d/50-#{fetch :application}.conf
      SCRIPT
    end
  end

  task :reload_daemons do
    on roles :all do
      execute :sudo, 'systemctl daemon-reload'
    end
  end
end

before 'deploy:restart', 'deploy:reload_daemons'
