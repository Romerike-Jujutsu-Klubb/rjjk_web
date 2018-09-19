# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

COOKIE_SCOPE = if Rails.env.production?
                 { domain: :all, tld_length: 2 }
               # elsif Rails.env.heroku?
               #   { domain: 'jujutsu-no.herokuapp.com' }
               elsif Rails.env.beta?
                 { domain: 'beta.jujutsu.no' }
               else
                 {}
               end

Rails.application.config.session_store :cookie_store,
    { key: "_rjjk_web#{"_#{Rails.env}" unless Rails.env.production?}_session" }.merge(COOKIE_SCOPE)
