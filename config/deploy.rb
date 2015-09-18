lock '~>3.4'

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'public/attendances', 'public/images', 'public/members', 'tmp')
set :default_env, {JRUBY_OPTS: '"--dev -J-Xmx2G"'}
set :rvm_ruby_version, File.read(File.expand_path('../.ruby-version', File.dirname(__FILE__))).strip
set :pty, true

before 'deploy:restart', 'deploy:reload_daemons'
after 'deploy:publishing', 'deploy:restart'

desc 'Announce maintenance'
task :announce_maintenance do
  on roles :all do
    within("#{current_path}/public") { execute :cp, '503_update.html 503.html' }
  end
end
before 'deploy:starting', :announce_maintenance

desc 'Announce maintenance in the release area'
task :announce_maintenance_release do
  on roles :all do
    within("#{release_path}/public") { execute :cp, '503_update.html 503.html' }
  end
end
after 'deploy:updated', :announce_maintenance_release

desc 'End maintenance'
task :end_maintenance do
  on roles :all do
    within("#{current_path}/public") { execute :cp, '503_down.html 503.html' }
  end
end
after 'deploy:finished', :end_maintenance

namespace :deploy do
  task :symlinks do
    on roles :all do
      execute :sudo, <<-SCRIPT
        echo "Updating init script"
        rm -f /usr/lib/systemd/system/#{fetch :application}.service
        sudo cp -a #{current_path}/usr/lib/systemd/system/#{fetch :application}.service /usr/lib/systemd/system/#{fetch :application}.service
      SCRIPT
    end
  end

  task :reload_daemons do
    on roles :all do
      execute :sudo, 'systemctl daemon-reload'
    end
  end
end

task :smoke_test do
  system "rake smoke_test RAILS_ENV=#{fetch(:rails_env)}"
end
after :deploy, :smoke_test

desc 'Update the MRI bundle'
task :bundle_mri do
  on roles :all do
    within(current_path) do
      execute "#{fetch :rvm_path}/bin/rvm 2.2.2 do bundle --gemfile=#{current_path}/Gemfile"
    end
  end
end
after :deploy, :bundle_mri
