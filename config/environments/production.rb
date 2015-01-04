Rails.application.configure do
  config.action_controller.perform_caching = true
  # config.action_controller.asset_host = 'http://assets.example.com'
  # config.action_dispatch.rack_cache = true
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX
  config.action_mailer.default_url_options = {host: 'jujutsu.no'}
  config.action_mailer.raise_delivery_errors = true
  config.active_record.dump_schema_after_migration = false
  config.active_support.deprecation = :notify
  # config.assets.css_compressor = :sass
  config.assets.compile = false
  config.assets.digest = true
  config.assets.js_compressor = :uglifier
  config.cache_classes = true
  # config.cache_store = :mem_cache_store
  config.consider_all_requests_local = false
  config.eager_load = true
  # config.force_ssl = true
  config.i18n.fallbacks = true
  config.log_formatter = ::Logger::Formatter.new
  config.log_level = :debug
  # config.log_tags = [ :subdomain, :uuid ]
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)
  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?
end
