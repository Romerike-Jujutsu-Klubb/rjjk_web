# frozen_string_literal: true

Rails.application.configure do
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_controller.asset_host = 'http://assets.example.com'
  config.action_controller.perform_caching = true
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  config.action_mailer.asset_host = 'https://www.jujutsu.no'
  config.action_mailer.default_url_options = { protocol: 'https', host: 'www.jujutsu.no' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    user_name: ENV['SMTP_USERNAME'],
    password: ENV['SMTP_PASSWORD'],
    address: ENV['SMTP_SERVER'],
    domain: 'jujutsu.no',
    port: 587,
    authentication: :login,
    enable_starttls_auto: true,
    openssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,
  }
  config.action_mailer.perform_caching = true
  # config.action_mailer.raise_delivery_errors = false
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "rjjk_web_#{Rails.env}"
  # config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  # config.active_record.database_resolver_context =
  #     ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
  # config.active_record.database_selector = { delay: 2.seconds }
  config.active_record.dump_schema_after_migration = false
  config.active_storage.service = :db
  config.active_support.deprecation = :notify
  config.assets.compile = false
  # config.assets.css_compressor = :sass
  config.assets.js_compressor = Uglifier.new(harmony: true)
  config.cache_classes = true
  config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] } if ENV['REDIS_URL']
  config.consider_all_requests_local = false
  config.eager_load = true
  config.force_ssl = true
  config.i18n.fallbacks = true
  config.log_formatter = ::Logger::Formatter.new
  config.log_level = ENV['RAILS_LOG_LEVEL'] || :info
  config.log_tags = [:request_id]
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')
  config.lograge.enabled = true
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.year.to_i}",
  }
  config.require_master_key = true
  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end
end

%w[render_template render_partial render_collection].each do |event|
  ActiveSupport::Notifications.unsubscribe "#{event}.action_view"
end
