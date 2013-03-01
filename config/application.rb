require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  # Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  Bundler.require(:default, :assets, Rails.env)
end

module RjjkWeb
  class Application < Rails::Application
    config.time_zone = 'UTC'
    config.i18n.default_locale = :nb
    config.encoding = Encoding::UTF_8
    config.filter_parameters += [:content_data, :file, :image, :password]
    config.assets.enabled = true
    config.assets.version = '1.0'
    config.assets.initialize_on_precompile = false
  end
end
