# frozen_string_literal: true

require_relative 'production'
Rails.application.configure do
  # config.action_controller.allow_forgery_protection = false # for siege
  config.action_mailer.asset_host = 'https://jujutsu-no.herokuapp.com'
  config.action_mailer.default_url_options = { protocol: 'https', host: 'jujutsu-no.herokuapp.com' }
  config.log_level = :debug
end
