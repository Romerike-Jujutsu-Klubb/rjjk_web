Rails.application.configure do
  config.action_controller.perform_caching = true
  config.action_mailer.default_url_options = {:host => 'beta.jujutsu.no'}
  config.action_mailer.raise_delivery_errors = true
  config.active_support.deprecation = :notify
  config.assets.compile = false
  config.assets.compress = true
  config.assets.digest = true
  config.cache_classes = true
  config.consider_all_requests_local = false
  config.eager_load = true
  config.i18n.fallbacks = true
  config.serve_static_assets = false
end
