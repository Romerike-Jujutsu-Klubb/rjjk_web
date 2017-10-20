# frozen_string_literal: true

threads_count = ENV.fetch('RAILS_MAX_THREADS') { RUBY_ENGINE == 'jruby' ? 20 : 5 }
threads threads_count, threads_count
port ENV.fetch('PORT') { 3000 }
environment ENV.fetch('RAILS_ENV') { 'development' }
workers ENV.fetch('WEB_CONCURRENCY') { 2 } if RUBY_ENGINE == 'ruby'
prune_bundler
plugin :tmp_restart
