# frozen_string_literal: true

require 'http'
require 'cgi'

module Datek
  module Cpas
    BASE_URL = ENV['CPAS_API_BASE_URL'] ||
        (defined?(Rails) &&
            (Rails.application&.credentials&.cpas_api_base_url ||
                ((Rails.env.development? || Rails.env.test?) && 'https://example.com/sms'))) ||
        raise('CPAS_API_BASE_URL not set')

    def self.send_sms(to:, text:)
      ctx = OpenSSL::SSL::SSLContext.new
      ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
      HTTP.headers('content_type' => 'application/x-www-form-urlencoded')
          .post("#{BASE_URL}/send/mt", ssl_context: ctx,
              body: "to=#{CGI.escape to.to_s}&text=#{CGI.escape text}")
    end
  end
end
