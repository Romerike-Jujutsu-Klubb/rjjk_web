RjjkWeb::Application.configure do
  config.cache_classes = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_assets = false
  config.assets.compress = true
  config.assets.compile = false
  config.assets.digest = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { :host => 'beta.jujutsu.no' }
  config.threadsafe!
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
end

email_notification_options = {:email => {
    :email_prefix => '[RJJK BETA] ',
    :sender_address => '"BETA Exception Notifier" <noreply@beta.jujutsu.no>',
    :exception_recipients => %w{uwe@kubosch.no}
}}
RjjkWeb::Application.config.middleware.use ExceptionNotification::Rack, email_notification_options
