lock '~>3.4'

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'public/attendances',
    'public/images', 'public/members', 'tmp')
set :default_env, JRUBY_OPTS: '--dev', DISABLE_SCHEDULER: true
set :rvm_ruby_version, File.read(File.expand_path('../.ruby-version', File.dirname(__FILE__))).strip
set :pty, true

after 'deploy:updated', 'deploy:cleanup'
after 'deploy:publishing', 'deploy:restart'
