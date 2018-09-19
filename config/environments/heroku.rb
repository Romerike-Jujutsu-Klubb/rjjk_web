# frozen_string_literal: true

require_relative 'production'
Rails.application.configure do
  # config.action_controller.allow_forgery_protection = false # for siege
  config.action_mailer.asset_host = 'https://jujutsu-no.herokuapp.com'
  config.action_mailer.default_url_options = { protocol: 'https', host: 'jujutsu-no.herokuapp.com' }

  # Setup the mailer config
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.smtp_settings = {
    user_name: ENV['SENDGRID_USERNAME'],
    password: ENV['SENDGRID_PASSWORD'],
    domain: 'jujutsu.no',
    address: 'smtp.sendgrid.net',
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true,
  }

  config.log_level = :debug
end
