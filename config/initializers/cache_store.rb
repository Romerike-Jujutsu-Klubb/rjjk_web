# frozen_string_literal: true

if Rails.env.development? || ENV['LOG_CACHE_STORE'] == 'ENABLED'
  ActiveSupport::Cache::Store.logger = Rails.logger
end
