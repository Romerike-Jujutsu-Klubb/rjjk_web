# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  config.action_controller.allow_forgery_protection = false
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = false
  config.action_mailer.default_url_options = { protocol: 'https', host: 'example.com', port: nil }
  config.action_mailer.delivery_method = :test
  config.action_mailer.perform_caching = false
  # config.action_view.annotate_rendered_view_with_filenames = true
  config.active_storage.service = :test
  config.active_support.deprecation = :stderr
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []
  config.cache_classes = true
  # config.cache_store = :null_store # Keep commented to use FileStore to speed up tests significantly.
  config.consider_all_requests_local = true
  config.eager_load = false
  config.i18n.raise_on_missing_translations = true

  unless ENV['RAILS_ENABLE_TEST_LOG'] || caller.none? { |l| l =~ %r{/lib/rake/task.rb:\d+:in `execute'} }
    config.logger = Logger.new(nil)
    config.log_level = :fatal
  end

  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}",
  }

  if defined? Bullet
    config.after_initialize do
      Bullet.enable = true
      Bullet.bullet_logger = true
      Bullet.raise = true # raise an error if an n+1 query occurs
      # Bullet.alert = true
      Bullet.console = true
      Bullet.rails_logger = true
      # Bullet.add_footer = true
    end
  end
end
