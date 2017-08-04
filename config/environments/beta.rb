# frozen_string_literal: true

require_relative 'production'
Rails.application.configure do
  # config.action_controller.allow_forgery_protection = false # for siege
  config.action_mailer.asset_host = 'https://beta.jujutsu.no'
  config.action_mailer.default_url_options = { protocol: 'https', host: 'beta.jujutsu.no' }
  config.log_level = :debug
end
