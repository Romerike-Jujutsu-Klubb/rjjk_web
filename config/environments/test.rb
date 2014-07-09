RjjkWeb::Application.configure do
  config.cache_classes = true
  config.serve_static_assets = true
  config.static_cache_control = 'public, max-age=3600'
  config.whiny_nils = true
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = false
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = {:host => 'example.com'}
  config.active_record.mass_assignment_sanitizer = :strict
  config.active_support.deprecation = :stderr
  config.after_initialize { Timecop.freeze(Time.local 2013, 10, 17, 18, 46, 0) } # Week 42
  config.middleware.use ExceptionNotification::Rack, {
      :ignore_exceptions => [],
      :email => {
          :email_prefix => "[RJJK][#{Rails.env}] ",
          :sender_address => "\"RJJK #{Rails.env} Exception Notifier\" <noreply-#{Rails.env}@jujutsu.no>",
          :exception_recipients => %w{uwe@kubosch.no}
      }
  }
end
