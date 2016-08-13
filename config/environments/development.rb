Rails.application.configure do
  config.action_controller.perform_caching = false
  config.action_mailer.asset_host = 'http://localhost:3000'
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.action_mailer.raise_delivery_errors = true
  config.action_view.raise_on_missing_translations = true
  config.active_record.migration_error = :page_load
  config.active_support.deprecation = :log
  config.assets.debug = false
  config.assets.digest = true
  config.assets.raise_runtime_errors = true
  config.cache_classes = false
  config.consider_all_requests_local = true
  config.eager_load = false
end
