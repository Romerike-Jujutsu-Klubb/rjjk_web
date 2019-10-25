# frozen_string_literal: true

HOSTED = %w[production beta].include?(get(:environment))
threads_count = ENV.fetch('RAILS_MAX_THREADS') { HOSTED ? 5 : 1 }
threads threads_count, threads_count
port ENV.fetch('PORT') { 3000 }
environment ENV.fetch('RAILS_ENV') { 'development' }
workers ENV.fetch('WEB_CONCURRENCY') { 2 } if HOSTED
preload_app!
plugin :tmp_restart

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
