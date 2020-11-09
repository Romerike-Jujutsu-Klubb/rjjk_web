# frozen_string_literal: true

env = ENV.fetch('RAILS_ENV', 'development')
hosted = %w[production beta].include?(env)

max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 6)
min_threads_count = ENV.fetch('RAILS_MIN_THREADS') { max_threads_count }
threads min_threads_count, max_threads_count
port ENV.fetch('PORT', 3000)
environment env
pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')
worker_count = ENV.fetch('WEB_CONCURRENCY', hosted ? 2 : 0).to_i
if worker_count > 1
  workers worker_count
  preload_app!
  on_worker_boot { ActiveRecord::Base.establish_connection }
else
  workers 0
  prune_bundler
end
plugin :tmp_restart
