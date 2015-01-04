Rails.application.configure do
  config.action_controller.allow_forgery_protection = false
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = false
  config.action_mailer.default_url_options = {host: 'example.com'}
  config.action_mailer.delivery_method = :test
  config.active_support.deprecation = :stderr
  config.active_support.test_order = :random
  # config.action_view.raise_on_missing_translations = true
  config.cache_classes = true
  config.consider_all_requests_local = true
  config.eager_load = true
  config.serve_static_files = true
  config.static_cache_control = 'public, max-age=3600'
  config.after_initialize { Timecop.freeze(Time.local 2013, 10, 17, 18, 46, 0) } # Week 42, thursday
end
