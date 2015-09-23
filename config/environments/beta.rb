require_relative 'production'
Rails.application.configure do
  # config.action_controller.allow_forgery_protection = false # for siege
  config.action_mailer.asset_host = 'http://beta.jujutsu.no'
  config.action_mailer.default_url_options = {host: 'beta.jujutsu.no'}
  config.log_level = :debug
end
