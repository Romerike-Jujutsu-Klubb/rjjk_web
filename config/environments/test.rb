# frozen_string_literal: true

Rails.application.configure do
  config.action_controller.allow_forgery_protection = false
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = false
  config.action_mailer.asset_host = 'https://example.com'
  config.action_mailer.default_url_options = { protocol: 'https', host: 'example.com' }
  config.action_mailer.delivery_method = :test
  config.action_mailer.perform_caching = false
  config.action_view.raise_on_missing_translations = true
  config.active_support.deprecation = :stderr
  config.cache_classes = true
  config.consider_all_requests_local = true
  config.eager_load = false
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.seconds.to_i}",
  }
  # config.read_encrypted_secrets = true

  if defined? Bullet
    config.after_initialize do
      # Bullet.enable = true
      Bullet.bullet_logger = true
      Bullet.raise = true # raise an error if an n+1 query occurs
    end
  end
end
