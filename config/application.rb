# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RjjkWeb
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    # FIXME(uwe): Run `bin/rails zeitwerk:check` after loading Rails 6.0 defaults

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Cannot be moved to initializer:
    # https://github.com/rails/rails/issues/24748
    # https://github.com/rails/rails/pull/34985
    config.time_zone = 'Copenhagen'
  end
end
