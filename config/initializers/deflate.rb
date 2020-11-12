# frozen_string_literal: true

if Rails.application.config.public_file_server.enabled
  Rails.application.config.middleware.insert_after ActionDispatch::Static, Rack::Deflater
end
