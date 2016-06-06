Rails.application.configure do
  # config.action_controller.asset_host = 'http://assets.example.com'
  config.action_controller.perform_caching = true
  # config.action_dispatch.rack_cache = true
  config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  config.action_mailer.asset_host = 'http://jujutsu.no'
  config.action_mailer.default_url_options = {host: 'jujutsu.no'}
  config.action_mailer.raise_delivery_errors = true
  config.active_record.dump_schema_after_migration = false
  config.active_support.deprecation = :notify
  config.assets.compile = false
  config.assets.css_compressor = :sass
  config.assets.digest = true
  config.assets.js_compressor = :uglifier
  config.cache_classes = true
  # config.cache_store = :file_store, "/path/to/cache/directory"
  # config.cache_store = :mem_cache_store
  # config.cache_store = :mem_cache_store, "cache-1.example.com"
  # config.cache_store = :memory_store, { size: 64.megabytes }
  config.consider_all_requests_local = false
  config.eager_load = true
  config.i18n.fallbacks = true
  config.log_formatter = ::Logger::Formatter.new
  config.log_level = :info
  # config.log_tags = [ :subdomain, :uuid ]
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)
  config.lograge.enabled = true
  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?
end

%w{render_template render_partial render_collection}.each do |event|
  ActiveSupport::Notifications.unsubscribe "#{event}.action_view"
end
