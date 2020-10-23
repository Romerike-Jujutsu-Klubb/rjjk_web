# frozen_string_literal: true

HOSTED = %w[production beta].include?(get(:environment))
max_threads_count = ENV.fetch('RAILS_MAX_THREADS') { HOSTED ? 5 : 1 }
min_threads_count = ENV.fetch('RAILS_MIN_THREADS') { max_threads_count }
threads min_threads_count, max_threads_count
port ENV.fetch('PORT', 3000)
environment ENV.fetch('RAILS_ENV', 'development')
pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')
worker_count = Integer(ENV.fetch('WEB_CONCURRENCY', 2))
if worker_count > 1
  workers worker_count if HOSTED
  preload_app!
  on_worker_boot { ActiveRecord::Base.establish_connection }
end
plugin :tmp_restart
