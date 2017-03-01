# frozen_string_literal: true
require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RjjkWeb
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.active_record.time_zone_aware_types = [:datetime]
    config.i18n.available_locales = [:nb, :en]
    config.i18n.default_locale = :nb
    config.time_zone = 'Copenhagen'
  end
end
