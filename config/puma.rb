# frozen_string_literal: true

threads_count = ENV.fetch('RAILS_MAX_THREADS') { 5 }
threads threads_count, threads_count
port ENV.fetch('PORT') { 3000 }
environment ENV.fetch('RAILS_ENV') { 'development' }
workers ENV.fetch('WEB_CONCURRENCY') { 2 } if %w[production beta].include?(get(:environment))
preload_app!
plugin :tmp_restart

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
