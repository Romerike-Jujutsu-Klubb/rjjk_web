# frozen_string_literal: true

lock '~>3.4'

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'public/attendances',
    'public/images', 'public/members', 'tmp')
set :default_env, JRUBY_OPTS: '--dev -J-Xmx2G', DISABLE_SCHEDULER: true
set :rvm_ruby_version,
    File.read(File.expand_path('../.ruby-version-production', __dir__)).strip
set :mri_ruby_version,
    File.read(File.expand_path('../.ruby-version', __dir__)).strip
set :pty, true

after 'deploy:updated', 'deploy:cleanup'
after 'deploy:publishing', 'deploy:restart'
