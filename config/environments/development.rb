# frozen_string_literal: true
Rails.application.configure do
  config.action_mailer.asset_host = 'http://localhost:3000'
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.action_mailer.perform_caching = false
  config.action_mailer.raise_delivery_errors = true
  config.action_view.raise_on_missing_translations = true
  config.active_record.migration_error = :page_load
  config.active_support.deprecation = :log
  config.assets.debug = false
  config.assets.quiet = true
  config.cache_classes = false
  config.consider_all_requests_local = true
  config.eager_load = false
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.cache_store = :memory_store
    config.public_file_server.headers = {
        'Cache-Control' => 'public, max-age=172800',
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end
end
