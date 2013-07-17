RjjkWeb::Application.configure do
  config.action_controller.perform_caching = false
  config.action_dispatch.best_standards_support = :builtin
  config.action_mailer.default_url_options = {host: 'localhost', port: 3000}
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.active_record.auto_explain_threshold_in_seconds = 0.5
  config.active_record.mass_assignment_sanitizer = :strict
  config.active_support.deprecation = :log
  config.assets.compress = false
  config.assets.debug = true
  config.cache_classes = false
  config.consider_all_requests_local = true
  config.serve_static_assets = true
  config.whiny_nils = true
end

email_notification_options = {
    :ignore_exceptions => [],
    :email => {
        :email_prefix => '[RJJK][Development] ',
        :sender_address => '"Exception Notifier" <noreply@jujutsu.no>',
        :exception_recipients => %w{uwe@kubosch.no}
    }
}
RjjkWeb::Application.config.middleware.use ExceptionNotification::Rack, email_notification_options
