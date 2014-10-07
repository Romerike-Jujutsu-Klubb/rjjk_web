Rails.application.configure do
  config.action_controller.perform_caching = true

  config.action_mailer.default_url_options = {host: 'jujutsu.no'}
  # config.action_mailer.delivery_method = :sendmail
  # config.action_mailer.perform_deliveries = true
  # config.action_mailer.raise_delivery_errors = true

  config.active_record.dump_schema_after_migration = false
  config.active_support.deprecation = :notify
  config.assets.compile = false
  config.assets.compress = true
  config.assets.digest = true
  config.assets.js_compressor = :uglifier
  config.cache_classes = true
  config.consider_all_requests_local = false
  config.eager_load = true
  config.i18n.fallbacks = true
  config.log_formatter = ::Logger::Formatter.new
  config.log_level = :info
  config.serve_static_assets = false
end
