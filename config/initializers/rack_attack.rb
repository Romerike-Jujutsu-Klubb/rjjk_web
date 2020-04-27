# frozen_string_literal: true

USER_VALID_PATTERN = %r{/users/\d+/valid }.freeze

if Rails.env.test?
  Rack::Attack.enabled = false
else
  class Rack::Attack
    safelist('PWA') do |request|
      ['/manifest.json', '/offline.html', '/serviceworker.js'].include?(request.path) ||
          (USER_VALID_PATTERN.match?(request.path) && request.env['rack.session']['user_id'])
    end

    throttle('req/ip', limit: 300, period: 5.minutes, &:ip)
    throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
      req.ip if req.path =~ %r{/login} && req.post?
    end
    throttle('logins/email', limit: 5, period: 20.seconds) do |req|
      req.params['email'].presence if req.path =~ %r{/login} && req.post?
    end
    throttle('logins/key', limit: 5, period: 20.seconds) { |req| req.params['key'].presence && :key }
  end
end
