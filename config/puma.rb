# frozen_string_literal: true

threads_count = ENV.fetch('RAILS_MAX_THREADS') { RUBY_ENGINE == 'jruby' ? 20 : 5 }
threads threads_count, threads_count
port ENV.fetch('PORT') { 3000 }
environment ENV.fetch('RAILS_ENV') { 'development' }
if %w[production beta].include?(ENV['RAILS_ENV']) && RUBY_ENGINE == 'ruby'
  workers ENV.fetch('WEB_CONCURRENCY') { 2 }
end
prune_bundler
plugin :tmp_restart
