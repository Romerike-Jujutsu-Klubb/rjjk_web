# frozen_string_literal: true

Rails.application.configure do
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_controller.asset_host = 'http://assets.example.com'
  config.action_controller.perform_caching = true
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  config.action_mailer.asset_host = 'https://jujutsu.no'
  config.action_mailer.default_url_options = { protocol: 'https', host: 'jujutsu.no' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    user_name: ENV['SMTP_USERNAME'],
    password: ENV['SMTP_PASSWORD'],
    domain: 'jujutsu.no',
    address: 'smtp.webhuset.no',
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true,
  }
  config.action_mailer.perform_caching = true
  # config.action_mailer.raise_delivery_errors = false
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "rjjk_web_#{Rails.env}"
  config.active_record.dump_schema_after_migration = false
  config.active_storage.service = :local
  config.active_support.deprecation = :notify
  config.assets.compile = false
  # config.assets.css_compressor = :sass
  config.assets.js_compressor = :uglifier
  config.cache_classes = true
  # config.cache_store = :mem_cache_store
  config.consider_all_requests_local = false
  config.eager_load = true
  # config.force_ssl = true # FIXME(uwe): Enable when we have paid dynos on Heroku
  config.i18n.fallbacks = true
  config.log_formatter = ::Logger::Formatter.new
  config.log_level = :debug
  config.log_tags = [:request_id]
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')
  config.lograge.enabled = true
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.require_master_key = true
  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end
  config.middleware.use Rack::Attack
end

%w[render_template render_partial render_collection].each do |event|
  ActiveSupport::Notifications.unsubscribe "#{event}.action_view"
end
