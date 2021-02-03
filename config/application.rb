# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RjjkWeb
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    # FIXME(uwe): Run `bin/rails zeitwerk:check` after loading Rails 6.0 defaults

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Cannot be moved to initializer:
    # https://github.com/rails/rails/issues/24748
    # https://github.com/rails/rails/pull/34985
    config.time_zone = 'Copenhagen'
  end
end
