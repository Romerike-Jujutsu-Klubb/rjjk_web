# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

if Rails.env.production?
  Rails.application.config.session_store :cookie_store, key: '_rjjk_web_session', domain: :all
elsif Rails.env.beta?
  Rails.application.config.session_store :cookie_store, key: '_rjjk_web_beta_session',
      domain: 'beta.jujutsu.no'
else
  Rails.application.config.session_store :cookie_store, key: '_rjjk_web_session'
end
