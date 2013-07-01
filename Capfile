load 'deploy'
load 'deploy/assets'

set :stages, %w(beta production)
set :default_stage, 'beta'

require 'rubygems'
require 'bundler/capistrano'
require 'capistrano/ext/multistage'

desc 'Fix permission'
task :fix_permissions, :roles => [:app, :db, :web] do
  run "#{try_sudo} chmod +rx #{current_path}"
end

after 'deploy:create_symlink', :fix_permissions
